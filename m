From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Thu, 16 Apr 2009 12:17:28 -0400
Message-ID: <49E75A18.7020002@hp.com>
References: <49E710E1.3060209@miraclelinux.com>	<20090416.043800.171462037.davem@davemloft.net> <20090416083031.1cc24489@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ysugiura@miraclelinux.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:25692 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463AbZDPQRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:17:31 -0400
In-Reply-To: <20090416083031.1cc24489@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 16 Apr 2009 04:38:00 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Yuta sugiura <ysugiura@miraclelinux.com>
>> Date: Thu, 16 Apr 2009 20:05:05 +0900
>>
>>> Hi,
>>> I have a suggestion about /proc/net/IPv6_route format.
>>> In rt6_info_route(), interface name is treated as a maximum 8
>>> characters.
>>> But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ=
>>> 16]
>>> so, I think that it should change "%8s" to "%16s".
>> Isn't there a way to pass the field length as a paramenter
>> to formatting functions?  Then we can just pass in
>> IFNAMESIZE as that parameter.
> 
> 	seq_printf(m, " %08x %08x %08x %08x %*s\n"
>                    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
>  		   rt->u.dst.__use, rt->rt6i_flags,
>                    IFNAMESIZE, 
>  		   rt->rt6i_dev ? rt->rt6i_dev->name : "")

Does the kernel actually truncate an interface name more than 8 chars long in
the original version?  I did a quick test in userspace and found that

	printf("%*s\n", 1, "foo");

prints:

foo

I think the width specifier is used for *minimum* width, not maximum.

-Brian
