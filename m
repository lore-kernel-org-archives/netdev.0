From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Thu, 16 Apr 2009 18:47:04 +0200
Message-ID: <m2y6u07dh3.fsf@igel.home>
References: <49E710E1.3060209@miraclelinux.com>
	<20090416.043800.171462037.davem@davemloft.net>
	<20090416083031.1cc24489@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ysugiura@miraclelinux.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:53911 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001AbZDPQrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:47:10 -0400
In-Reply-To: <20090416083031.1cc24489@nehalam> (Stephen Hemminger's message of
	"Thu, 16 Apr 2009 08:30:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Thu, 16 Apr 2009 04:38:00 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Yuta sugiura <ysugiura@miraclelinux.com>
>> Date: Thu, 16 Apr 2009 20:05:05 +0900
>> 
>> > Hi,
>> > I have a suggestion about /proc/net/IPv6_route format.
>> > In rt6_info_route(), interface name is treated as a maximum 8
>> > characters.
>> > But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ=
>> > 16]
>> > so, I think that it should change "%8s" to "%16s".
>> 
>> Isn't there a way to pass the field length as a paramenter
>> to formatting functions?  Then we can just pass in
>> IFNAMESIZE as that parameter.
>
> 	seq_printf(m, " %08x %08x %08x %08x %*s\n"
>                    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
>  		   rt->u.dst.__use, rt->rt6i_flags,
>                    IFNAMESIZE, 
>  		   rt->rt6i_dev ? rt->rt6i_dev->name : "")

Actually since it is the last item on the line a field width does not
make much sense, and omitting it would print the name left justified.

(And RT6_INFO_LEN is not used any more.)

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
