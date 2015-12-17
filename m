From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] cxgb4: Use mask & shift while returning
 vlan_prio
Date: Wed, 16 Dec 2015 23:20:08 -0500 (EST)
Message-ID: <20151216.232008.805617588685597196.davem@davemloft.net>
References: <1450251988-9246-2-git-send-email-hariprasad@chelsio.com>
	<20151216.190733.272791166074460566.davem@davemloft.net>
	<B7C06B31-B31A-453D-AA4E-4C836056832E@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbbLQEUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 23:20:13 -0500
In-Reply-To: <B7C06B31-B31A-453D-AA4E-4C836056832E@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Wed, 16 Dec 2015 17:40:41 -0800

> 
>> On Dec 16, 2015, at 4:07 PM, David Miller <davem@davemloft.net> wrote:
>> 
>> From: Hariprasad Shenai <hariprasad@chelsio.com>
>> Date: Wed, 16 Dec 2015 13:16:25 +0530
>> 
>>> @@ -66,7 +66,7 @@ struct l2t_data {
>>> 
>>> static inline unsigned int vlan_prio(const struct l2t_entry *e)
>>> {
>>> -	return e->vlan >> 13;
>>> +	return (e->vlan & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
>> 
>> e->vlan is a u16, the vlan priotity is the top 3 bits of the 16-bit
>> value, and finally the right shift will be non-signed.
>> 
>> Therefore this change is absolutely not necessary.
>> 
>> Please remove this patch from the series and resend.
> 
> I assume that you only meant that the masking portion is
> unnecessary.  Doing the shift with the symbolic constant
> VLAN_PRIO_SHIFT instead of the literal constant “13” is still a
> reasonable change.  The masking was almost certainly from me because
> once one uses the symbolic constants, weren’t not supposed to “know”
> about the internal structure of the operation.  Modern compilers are
> of course free to optimize away the mask, etc.

Yes I'm only objecting to the unnecessary mask operation.
