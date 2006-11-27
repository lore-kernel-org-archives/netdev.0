From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] potential NULL pointer deref in net/key/af_key.c
Date: Mon, 27 Nov 2006 13:53:33 -0800 (PST)
Message-ID: <20061127.135333.28790424.davem@davemloft.net>
References: <200611272244.08189.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gem@asplinux.ru, davem@redhat.com, kuznet@ms2.inr.ac.ru,
	kunihiro@ipinfusion.com, miyazawa@linux-ipv6.org, derek@ihtfp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56478
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933840AbWK0Vxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 16:53:30 -0500
To: jesper.juhl@gmail.com
In-Reply-To: <200611272244.08189.jesper.juhl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Mon, 27 Nov 2006 22:44:07 +0100

> In net/key/af_key.c::pfkey_send_policy_notify() there's a check at the 
> beginning of the function : 
> 
>     if (xp && xp->type != XFRM_POLICY_TYPE_MAIN)
> 
> this implies that 'xp' may be null when the function is called. But later 
> on in the function we have this code : 
> 
>     return key_notify_policy(xp, dir, c);
> 
> key_notify_policy() passes 'xp' to pfkey_xfrm_policy2msg_prep() that pass
> it on to pfkey_xfrm_policy2msg_size() which dereferences it.
> key_notify_policy() also passes 'xp' to pfkey_xfrm_policy2msg() which 
> also dereferences it.
> 
> So, in pfkey_send_policy_notify() in the cases where we end up calling 
> key_notify_policy(), we should test 'xp' for NULL.
> 
> (note: patch is compile tested only)
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

We really need to teach your automated tool about context.

The NULL case can only occur for XFRM_MSG_FLUSHPOLICY.

Look at the km_policy_notify() call sites.  You can even see from the
net/xfrm/xfrm_user.c:xfrm_send_policy_notify() implementation of this
callback that for XFRM_MSG_FLUSHPOLICY the "xp" argument is ignored.
