From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 1/1] ipv6: add support of ECMP
Date: Wed, 12 Sep 2012 18:42:13 +0900
Message-ID: <505058F5.9020707@linux-ipv6.org>
References: <87a9x3vxzp.fsf@guybrush.luffy.cx> <1347438597-4233-1-git-send-email-nicolas.dichtel@6wind.com> <1347438597-4233-2-git-send-email-nicolas.dichtel@6wind.com> <50504C72.1090500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, bernat@luffy.cx,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46635 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753218Ab2ILJmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 05:42:22 -0400
In-Reply-To: <50504C72.1090500@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

YOSHIFUJI Hideaki wrote:
> Hello.
> 
> Nicolas Dichtel wrote:
>> This patch adds the support of equal cost multipath for IPv6.
>>
>> The patch is based on a previous work from
>> Luc Saillard <luc.saillard@6wind.com>.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> :
>> +config IPV6_MULTIPATH
>> +	bool "IPv6: equal cost multipath for IPv6 routing"
>> +	depends on IPV6
>> +	default y
>> +	---help---
>> +	  Enable this option to support ECMP for IPv6.
>> +	  If unsure, say N.
>> +
>> +choice
>> +	prompt "IPv6: choose Multipath algorithm"
>> +	depends on IPV6_MULTIPATH
>> +	default IPV6_MULTIPATH_ROUTE
>> +	---help---
>> +	  Define the method to select route between each possible path.
>> +
>> +	config IPV6_MULTIPATH_ROUTE
>> +	bool "IPv6: MULTIPATH flow algorithm"
>> +	---help---
>> +	  Multipath routes are chosen according to hash of packet header to
>> +	  ensure a flow keeps the same route.
>> +
>> +	config IPV6_MULTIPATH_RR
>> +	bool "IPv6: MULTIPATH round robin algorithm"
>> +	---help---
>> +	  Multipath routes are chosen according to Round Robin.
>> +
>> +	config IPV6_MULTIPATH_RANDOM
>> +	bool "IPv6: MULTIPATH random algorithm"
>> +	---help---
>> +	  Multipath routes are chosen in a random fashion.
>> +endchoice
> 
> We should use hash-based algorithm by default,
> according to RFC4311.  See also RFC6438.

Sorry, I missed something and misunderstood.


I prefer "HASH" of "FLOW" instead of "ROUTE"
because it select route by "hash" or "flow"
(as other options mean; by "round-robin"(RR) or by "random"(RANDOM)).

And, please clearly specify that it is the recommended
the default and recommended algorithm.
(We may have references to RFCs.)

Default is "y" but description says "if unsure, say N."
This is not good.


Of course, we may want to take "flow label" into account
when calculating hash (RFC6438).

Regards,

-----
[*] IPv6: equal cost multipath for IPv6 routing

    Enable this option to support ECMP for IPv6.

 [*] IPv6: MULTIPATH hash-based algorithm

      Multipath routes are chosen according to hash of packet
      header information (source, destination, ...)
      to ensure a flow keeps the same route.

      This is the default and recommended.

 [ ] IPv6: MULTIPATH round-robin algorithm
 [ ] IPv6: MULTIPATH random algorithm

--yoshfuji
