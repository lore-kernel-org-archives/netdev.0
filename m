From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC 0/9] snet: Security for NETwork syscalls
Date: Tue, 5 Jan 2010 08:09:17 -0600
Message-ID: <20100105140917.GA6624@us.ibm.com>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
 <1262537872.10218.27.camel@bigi>
 <m2r5q5nhbc.fsf@ssh.synack.fr>
 <201001050820.o058Kuwx087793@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sam@synack.fr, linux-security-module@vger.kernel.org,
	kaber@trash.net, zbr@ioremap.net, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	hadi@cyberus.ca
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60244 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab0AEOJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 09:09:47 -0500
Content-Disposition: inline
In-Reply-To: <201001050820.o058Kuwx087793@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Tetsuo Handa (penguin-kernel@I-love.SAKURA.ne.jp):
> Samir Bellabes wrote:
> > I'm currently testing security_sock_rcv_skb() hook - which is inside
> > sk_filter() - to get skbuffs when then are arriving, and so trying to
> > push the buffer to userspace. In case this is not userfull, userspace
> > is able to use the NFQUEUE of netfilter to get skbuff, and deal
> > with incoming datas.
> 
> Pushing buffer to userspace and wait for userspace's decision will sleep.
> sk_filter() which calls security_sock_rcv_skb() hook is called from
> (e.g.) tcp_v6_do_rcv() and comment of tcp_v6_do_rcv() says that
> "The socket must have it's spinlock held when we get here." 
> Also, comment of rxrpc_queue_rcv_skb() says that
> "the caller must hold a lock on call->lock".
> I think it is not permitted to do sleeping operation inside
> security_sock_rcv_skb().

Ah, there it is, thanks for finding a specific instance.  I'd looked
a bit yesterday but couldn't find it.

Tetsuo, would you mind sending a patch to add a note to security.h's
comment for socket_sock_rcv_skb: that it can't sleep?  It also used
to be the case for security_task_free() which presumably would be
hooked by the ssyscall or whatever was mentioned.

thanks,
-serge
