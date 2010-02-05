From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC] xfrm: x86_64 CONFIG_COMPAT support
Date: Fri, 5 Feb 2010 20:54:09 +0100
Message-ID: <20100205195409.GB23792@Chamillionaire.breakpoint.cc>
References: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
 <20100204.202235.186522102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:44111 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932158Ab0BETyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 14:54:09 -0500
Content-Disposition: inline
In-Reply-To: <20100204.202235.186522102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 5 Feb 2010 02:47:44 +0100
> 
> > Unfortunately, the MSG_COMPAT flag seems to get lost along
> > the way, so this uses x86_64 is_compat_task() for now.
> 
> You can't use is_compat_task() for this.  The current
> execution context is not always the same as who is
> going to get the message.

Thank you, this saved me a lot of trouble.

I had a look at the wireless compat layer you mentioned;
when sending data to userspace one just prepares two
skbs (one native, one compat); netlink_recvmsg() then decides
which one to use for a particular receiver.

However, I believe I can use is_compat_task() on
the userspace -> kernel side to figure out how to interpret
the incoming data.

Is that correct or did I misunderstand?

Another way would be to first try native decode,
and then re-try compat format on error, but I consider that ugly.

Thanks for your help,
       Florian
