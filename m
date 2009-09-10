From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 18:19:00 -0700
Message-ID: <4AA85404.5020300@sun.com>
References: <4AA819D8.1020306@Sun.COM>
 <20090909.171517.34998160.davem@davemloft.net> <4AA84FE3.6030407@sun.com>
 <20090909.181033.25374239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Joyce.Yu@Sun.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:63298 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbZIJBUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:20:17 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n8A1KI4j013958
	for <netdev@vger.kernel.org>; Wed, 9 Sep 2009 18:20:18 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KPQ00J00E6K6100@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Wed,
 09 Sep 2009 18:20:18 -0700 (PDT)
In-reply-to: <20090909.181033.25374239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Matheos Worku <Matheos.Worku@Sun.COM>
> Date: Wed, 09 Sep 2009 18:01:23 -0700
> 
>> The frame type in NIU HW is embedded in a HW header, so it is possible
>> to check the HW header and decide whether to pull up ETH_HLEN or VLAN
>> header size of bytes. However, considering the amount of work required
>> to get and examine the HW header (including endianess issues), we
>> thought pulling up 64 bytes by default (as used in cassini.c) would be
>> efficient.
> 
> Well, it was 64 in early versions of the driver, and I decreased it
> down to ETH_HLEN.
> 
> The less the better since for forwarding applications anything past
> the IPV4 header pulled is going to be a waste of CPU cache lines and
> thus negatively effect forwarding rates.
> 
> That's why I asked if this change was performance regression tested,
> because I know it's going to slow down forwarding rates for small
> packets.
Dave,

We did throughput testing (netperf) and didn't notice any performance 
degradation. We haven't done forwarding testing however.

We can work on a version which implements HW header checking and do 
pullup accordingly.


Regards,
Matheos

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
