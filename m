From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 1/1] ipv6: add support of ECMP
Date: Wed, 12 Sep 2012 11:53:51 +0200
Message-ID: <50505BAF.6080507@6wind.com>
References: <87a9x3vxzp.fsf@guybrush.luffy.cx> <1347438597-4233-1-git-send-email-nicolas.dichtel@6wind.com> <1347438597-4233-2-git-send-email-nicolas.dichtel@6wind.com> <50504C72.1090500@linux-ipv6.org> <505058F5.9020707@linux-ipv6.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bernat@luffy.cx, netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50180 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab2ILJx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 05:53:57 -0400
Received: by eekc1 with SMTP id c1so1102522eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 02:53:56 -0700 (PDT)
In-Reply-To: <505058F5.9020707@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/09/2012 11:42, YOSHIFUJI Hideaki a =C3=A9crit :
> Hello.
>=20
> YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> Nicolas Dichtel wrote:
>>> This patch adds the support of equal cost multipath for IPv6.
>>>
>>> The patch is based on a previous work from
>>> Luc Saillard <luc.saillard@6wind.com>.
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> :
>>> +config IPV6_MULTIPATH
>>> +	bool "IPv6: equal cost multipath for IPv6 routing"
>>> +	depends on IPV6
>>> +	default y
>>> +	---help---
>>> +	  Enable this option to support ECMP for IPv6.
>>> +	  If unsure, say N.
>>> +
>>> +choice
>>> +	prompt "IPv6: choose Multipath algorithm"
>>> +	depends on IPV6_MULTIPATH
>>> +	default IPV6_MULTIPATH_ROUTE
>>> +	---help---
>>> +	  Define the method to select route between each possible path.
>>> +
>>> +	config IPV6_MULTIPATH_ROUTE
>>> +	bool "IPv6: MULTIPATH flow algorithm"
>>> +	---help---
>>> +	  Multipath routes are chosen according to hash of packet header =
to
>>> +	  ensure a flow keeps the same route.
>>> +
>>> +	config IPV6_MULTIPATH_RR
>>> +	bool "IPv6: MULTIPATH round robin algorithm"
>>> +	---help---
>>> +	  Multipath routes are chosen according to Round Robin.
>>> +
>>> +	config IPV6_MULTIPATH_RANDOM
>>> +	bool "IPv6: MULTIPATH random algorithm"
>>> +	---help---
>>> +	  Multipath routes are chosen in a random fashion.
>>> +endchoice
>>
>> We should use hash-based algorithm by default,
>> according to RFC4311.  See also RFC6438.
>=20
> Sorry, I missed something and misunderstood.
>=20
>=20
> I prefer "HASH" of "FLOW" instead of "ROUTE"
> because it select route by "hash" or "flow"
> (as other options mean; by "round-robin"(RR) or by "random"(RANDOM)).
Ok.

>=20
> And, please clearly specify that it is the recommended
> the default and recommended algorithm.
> (We may have references to RFCs.)
Ok.

>=20
> Default is "y" but description says "if unsure, say N."
> This is not good.
Yes, good catch.

>=20
>=20
> Of course, we may want to take "flow label" into account
> when calculating hash (RFC6438).
Ok, I will add it. I wait for others comments.


Regards,
Nicolas
