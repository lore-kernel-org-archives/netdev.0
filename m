From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv4/IPv6] Setting 0 for unused port field. (fwd)
Date: Tue, 25 Jul 2006 16:54:36 -0700 (PDT)
Message-ID: <20060725.165436.127672564.davem@davemloft.net>
References: <Pine.LNX.4.64.0607251045470.21222@d.namei>
	<20060725.235340.99246287.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28308
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030270AbWGYXyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 19:54:22 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060725.235340.99246287.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 25 Jul 2006 23:53:40 +0900 (JST)

> In article <Pine.LNX.4.64.0607251045470.21222@d.namei> (at Tue, 25 Jul 2006 10:45:51 -0400 (EDT)), James Morris <jmorris@namei.org> says:
> 
> > The recvmsg() for raw socket seems to return random u16 value
> > from the kernel stack memory since port field is not initialized.
> > But I'm not sure this patch is correct.
> > Does raw socket return any information stored in port field?
> > 
> > ---------- Start of patch ----------
> > diff -ur before/net/ipv4/raw.c after/net/ipv4/raw.c
> > --- before/net/ipv4/raw.c       2006-06-18 10:49:35.000000000 +0900
> > +++ after/net/ipv4/raw.c        2006-07-25 16:15:26.000000000 +0900
> > @@ -609,6 +609,7 @@
> >         if (sin) {
> >                 sin->sin_family = AF_INET;
> >                 sin->sin_addr.s_addr = skb->nh.iph->saddr;
> > +               sin->sin_port = 0;
> >                 memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
> >         }
> >         if (inet->cmsg_flags)
> 
> Well, instead, should it be initalized to protocol number, shouldn't it?

Initially, this was my reaction too.  But, aparently it is defined
to be zero, from TCP/IP Illustrated Volume 2, page 1055, which is
discussing rip_input() in the BSD stack:

	Unlike UDP, there is no concept of a port number in raw IP, so
	the sin_port field in the sockaddr_in structures is always 0.

The BSD code does not explicitly set it to zero.  But it doesn't have
to because it uses "ripsrc" which is a static variable in the BSS
section of the BSD kernel image.

So this patch appears correct and I will apply it.  Thanks everyone.
