From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 15 Aug 2016 12:19:31 -0700 (PDT)
Message-ID: <20160815.121931.301936006261567382.davem@davemloft.net>
References: <1471018418-12212-1-git-send-email-lorenzo@google.com>
	<20160815.105522.1444417738258658028.davem@davemloft.net>
	<7daa5c36-0167-f24b-ead2-45c49a82eb5c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, ek@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbcHOTTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 15:19:32 -0400
In-Reply-To: <7daa5c36-0167-f24b-ead2-45c49a82eb5c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 15 Aug 2016 12:44:27 -0600

> On 8/15/16 11:55 AM, David Miller wrote:
>> From: Lorenzo Colitti <lorenzo@google.com>
>> Date: Sat, 13 Aug 2016 01:13:38 +0900
>> 
>>> ping_v6_sendmsg does not set flowi6_oif in response to
>>> sin6_scope_id or sk_bound_dev_if, so it is not possible to use
>>> these APIs to ping an IPv6 address on a different interface.
>>> Instead, it sets flowi6_iif, which is incorrect but harmless.
>>>
>>> Stop setting flowi6_iif, and support various ways of setting oif
>>> in the same priority order used by udpv6_sendmsg.
>>>
>>> Tested: https://android-review.googlesource.com/#/c/254470/
>>> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>> 
>> I'm expecting a new version of this patch with changes handling
>> the situation that VRF needs.
> 
> The vrf situation does not apply here - at least not yet. Maybe I am
> missing something but ping_v6_sendmsg does not support IPV6_PKTINFO,
> so the potential oif override of sk_bound_dev_if is not there.
> 
> I'll add this to the to-do list -- make IPv6 compatible with IPv4
> wrt PKTINFO and then add in the VRF fix up discussed.

Ok, thanks for explaining.

Patch applied, t hanks.
