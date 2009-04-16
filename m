From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Thu, 16 Apr 2009 10:27:31 -0700
Message-ID: <20090416102731.459f9558@nehalam>
References: <49E710E1.3060209@miraclelinux.com>
	<20090416.043800.171462037.davem@davemloft.net>
	<20090416083031.1cc24489@nehalam>
	<m2y6u07dh3.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ysugiura@miraclelinux.com,
	netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45655 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbZDPR1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 13:27:37 -0400
In-Reply-To: <m2y6u07dh3.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009 18:47:04 +0200
Andreas Schwab <schwab@linux-m68k.org> wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > On Thu, 16 Apr 2009 04:38:00 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> >
> >> From: Yuta sugiura <ysugiura@miraclelinux.com>
> >> Date: Thu, 16 Apr 2009 20:05:05 +0900
> >> 
> >> > Hi,
> >> > I have a suggestion about /proc/net/IPv6_route format.
> >> > In rt6_info_route(), interface name is treated as a maximum 8
> >> > characters.
> >> > But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ=
> >> > 16]
> >> > so, I think that it should change "%8s" to "%16s".
> >> 
> >> Isn't there a way to pass the field length as a paramenter
> >> to formatting functions?  Then we can just pass in
> >> IFNAMESIZE as that parameter.
> >
> > 	seq_printf(m, " %08x %08x %08x %08x %*s\n"
> >                    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
> >  		   rt->u.dst.__use, rt->rt6i_flags,
> >                    IFNAMESIZE, 
> >  		   rt->rt6i_dev ? rt->rt6i_dev->name : "")
> 
> Actually since it is the last item on the line a field width does not
> make much sense, and omitting it would print the name left justified.
> 
> (And RT6_INFO_LEN is not used any more.)
> 
> Andreas.
> 

The issue is what happens if name is not null terminated. in this case
I bet the kernel already handles that.
