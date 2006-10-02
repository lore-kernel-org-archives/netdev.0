From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 09:31:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610020919050.9400@d.namei>
References: <20060925103836.GA13966@2ka.mipt.ru> <20060925112754.GA18228@gondor.apana.org.au>
 <20060925120519.GA19010@2ka.mipt.ru> <Pine.LNX.4.64.0609300037460.12011@d.namei>
 <Pine.LNX.4.64.0609300110190.12422@d.namei> <20060930111521.GA646@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301035020.26766@d.namei> <20060930144018.GA16918@2ka.mipt.ru>
 <Pine.LNX.4.64.0609301044090.26813@d.namei> <Pine.LNX.4.64.0610010203440.8658@d.namei>
 <20061002112050.GA772@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:6032 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932313AbWJBNbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 09:31:40 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002112050.GA772@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Evgeniy Polyakov wrote:

> > Evgeniy, please let me know if this fixes your problem.
> 
> With that patch applied I got kernel panic after some time.
> Unfortunately I have not installed serial console, so the most
> interesting bits of the stack dump are not visible.
> Here is the last ones which are on the screen:
> ip_rcv
> ip_rcv_finish
> packet_rcv_spkt
> ip_rcv
> netif_receive_skb
> sys_accept
> skge_poll
> 
> and some other uninteresting stuff like hrtimer, softirq and the like...
> 
> EIP is at xfrm_lookup+0x43d/0x470
> 
> Notice packet socket handler in the trace, may be it can help - I ran
> system with tcpdump started.

What kind of traffic was running over the system?  What is the IPsec and 
SELinux configuration?

Can you run gdb on vmlinux, find the start of xfrm_lookup then list what's 
at the EIP offset?

(gdb) p xfrm_lookup
$1 = {int (struct dst_entry **, struct flowi *, struct sock *, int)} 
0xc02cc7e2 <xfrm_lookup>
(gdb) l *(0xc02cc7e2 + 0x043d)


-- 
James Morris
<jmorris@namei.org>
