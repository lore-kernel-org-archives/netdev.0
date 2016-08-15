From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 15 Aug 2016 12:44:27 -0600
Message-ID: <7daa5c36-0167-f24b-ead2-45c49a82eb5c@cumulusnetworks.com>
References: <1471018418-12212-1-git-send-email-lorenzo@google.com>
 <20160815.105522.1444417738258658028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, ek@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: David Miller <davem@davemloft.net>, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36421 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbcHOSoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 14:44:30 -0400
Received: by mail-pf0-f178.google.com with SMTP id h186so19129591pfg.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 11:44:30 -0700 (PDT)
In-Reply-To: <20160815.105522.1444417738258658028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/16 11:55 AM, David Miller wrote:
> From: Lorenzo Colitti <lorenzo@google.com>
> Date: Sat, 13 Aug 2016 01:13:38 +0900
> 
>> ping_v6_sendmsg does not set flowi6_oif in response to
>> sin6_scope_id or sk_bound_dev_if, so it is not possible to use
>> these APIs to ping an IPv6 address on a different interface.
>> Instead, it sets flowi6_iif, which is incorrect but harmless.
>>
>> Stop setting flowi6_iif, and support various ways of setting oif
>> in the same priority order used by udpv6_sendmsg.
>>
>> Tested: https://android-review.googlesource.com/#/c/254470/
>> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> 
> I'm expecting a new version of this patch with changes handling
> the situation that VRF needs.

The vrf situation does not apply here - at least not yet. Maybe I am missing something but ping_v6_sendmsg does not support IPV6_PKTINFO, so the potential oif override of sk_bound_dev_if is not there.

I'll add this to the to-do list -- make IPv6 compatible with IPv4 wrt PKTINFO and then add in the VRF fix up discussed. 
