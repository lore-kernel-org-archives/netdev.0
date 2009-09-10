From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 18:01:23 -0700
Message-ID: <4AA84FE3.6030407@sun.com>
References: <4AA819D8.1020306@Sun.COM>
 <20090909.171517.34998160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Joyce.Yu@Sun.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:62822 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbZIJBCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:02:38 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n8A12f9O013017
	for <netdev@vger.kernel.org>; Wed, 9 Sep 2009 18:02:41 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KPQ00800DH2N400@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Wed,
 09 Sep 2009 18:02:41 -0700 (PDT)
In-reply-to: <20090909.171517.34998160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Joyce Yu <Joyce.Yu@sun.com>
> Date: Wed, 09 Sep 2009 14:10:48 -0700
> 
>> drivers/net/niu.h |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> Can I get a more verbose commit message than this?
> 
>> @@ -2700,7 +2700,7 @@ struct fcram_hash_ipv6 {
>> #define RCR_PKT_TYPE_UDP               0x2
>> #define RCR_PKT_TYPE_SCTP              0x3
>>
>> -#define NIU_RXPULL_MAX                 ETH_HLEN
>> +#define NIU_RXPULL_MAX                 64
>>
> 
> See, that's why I want a detailed commit message, because if you
> described things more clearly I'd understand why you choose the value
> '64' as opposed to, say, the size of a VLAN header which to me would
> be a more appropriate value to use here.

Dave,

The frame type in NIU HW  is embedded  in a  HW header,  so it is 
possible to check the HW header and decide whether to pull up ETH_HLEN 
or  VLAN header size of bytes. However, considering the amount of work 
required to get and examine the HW header (including endianess issues), 
we thought pulling up 64 bytes by default (as used in cassini.c) would 
be efficient.

Regards,
Matheos

> 
> You just seem to be reverting a change I made a while back, and it
> just so happens to fix your problem.  But '64' is too large a value
> to use here and it will impact performance.
> 
> You did check to see if there were any performance regressions
> resulting from your change, right?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
