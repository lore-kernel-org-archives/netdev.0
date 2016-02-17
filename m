From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/9] amd-xgbe: Disable VLAN filtering when
 in promiscuous mode
Date: Wed, 17 Feb 2016 11:31:06 -0500 (EST)
Message-ID: <20160217.113106.1360496601754038100.davem@davemloft.net>
References: <20160212143224.23973.91104.stgit@tlendack-t1.amdoffice.net>
	<20160216.201934.2034325737936595643.davem@davemloft.net>
	<56C49B3E.9030202@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423748AbcBQQbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 11:31:09 -0500
In-Reply-To: <56C49B3E.9030202@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 17 Feb 2016 10:09:34 -0600

> On 02/16/2016 07:19 PM, David Miller wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>> Date: Fri, 12 Feb 2016 08:32:24 -0600
>> 
>>> +#ifndef CRCPOLY_LE
>>> +#define CRCPOLY_LE 0xedb88320
>>> +#endif
>>> +static u32 xgbe_vid_crc32_le(__le16 vid_le)
>> 
>> Please do not implement yet another copy of a CRC implementation.
>> 
>> Make use of the various versions the kernel provides already instead,
>> add Kconfig dependencies as needed.
> 
> I can't use the existing kernel implementations because there aren't
> any that support the 12-bit length of the VLAN VID (lengths are all
> at the byte level). I created this function (back when I added VLAN
> filtering support in 2014 - it's only being moved in this patch)
> because of this 12-bit length.
> 
> I do use the kernel functions in other areas, I just can't use them
> here.

This crummy ifdef looks terrible though, is it even needed?

Please remove it.
