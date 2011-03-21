From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 08:54:21 +0100
Message-ID: <20110321075421.GA27581@secunet.com>
References: <4D86E603.8080704@cn.fujitsu.com>
 <20110320.225542.71119753.davem@davemloft.net>
 <4D86F1FD.3080009@cn.fujitsu.com>
 <20110320.234606.183056322.davem@davemloft.net>
 <4D86F4EA.6030909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34073 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733Ab1CUHyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 03:54:24 -0400
Content-Disposition: inline
In-Reply-To: <4D86F4EA.6030909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for catching this!

On Mon, Mar 21, 2011 at 02:49:14PM +0800, Wei Yongjun wrote:
> > Ok, thanks for the explanation.
> >
> > I think there is a simple way out of this:
> >
> > 1) Rename current xfrm_init_state to __xfrm_init_state, add
> >    "bool init_replay" argument.  Add the xfrm_init_replay()
> >    call, as in your patch, but conditionalized on this boolean.
> >
> > 2) Implement xfrm_init_state as inline, which calls
> >    __xfrm_init_state(..., true)
> >
> > 3) Replace xfrm_init_state() call in xfrm_user.c with
> >    __xfrm_init_state(..., false)
> >
> > This seems to avoid all the problems.  We don't need to touch every
> > caller, and we avoid initializing the replay state twice in xfrm_user
> >
> > Ok?
> 
> This OK, I will do this change, thanks.
> 

This looks ok for me too. I just noticed that we also need to clone the
replay_esn/preplay_esn informations and to reinitialize the sequence
number counting on XFRM MIGRATE from the original state before we
call xfrm_init_replay.

I'll fix this up once your patch is applied.

Thanks,

Steffen
