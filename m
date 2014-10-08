From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Wed, 08 Oct 2014 12:24:50 -0400 (EDT)
Message-ID: <20141008.122450.1919301744382855426.davem@davemloft.net>
References: <20141007.154425.2156753440391523455.davem@davemloft.net>
	<925ad10b2ec44e228e69bf0cbe6c0a0e@AMSPR05MB002.eurprd05.prod.outlook.com>
	<5434F989.2040101@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	talal@mellanox.com, yevgenyp@mellanox.com, netdev@vger.kernel.org,
	amirv@mellanox.com
To: moshel@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaJHQYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 12:24:55 -0400
In-Reply-To: <5434F989.2040101@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Lazer <moshel@dev.mellanox.co.il>
Date: Wed, 08 Oct 2014 11:44:57 +0300

>> #if defined(__i386__) || defined(__x86_64__)
>> 	if (map->type == _DRM_REGISTERS && !(map->flags & _DRM_WRITE_COMBINING))
>> 		tmp = pgprot_noncached(tmp);
>> 	else
>> 		tmp = pgprot_writecombine(tmp);
>> #elif defined(__powerpc__)
>> 	pgprot_val(tmp) |= _PAGE_NO_CACHE;
>> 	if (map->type == _DRM_REGISTERS)
>> 		pgprot_val(tmp) |= _PAGE_GUARDED;
>> #elif defined(__ia64__)
>> 	if (efi_range_is_wc(vma->vm_start, vma->vm_end -
>> 				    vma->vm_start))
>> 		tmp = pgprot_writecombine(tmp);
>> 	else
>> 		tmp = pgprot_noncached(tmp);
>> #elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
>> 	tmp = pgprot_noncached(tmp);
>> #endif
> The idea was to provide an indication as for whether the arch supports
> write-combining in general.
> If we want to benefit from blue flame operations, we need to map the
> blue flame registers as write combining - otherwise there is no
> benefit. So we would like to know if write combining is supported by
> the system or not.
> 

You completely miss my point.  On a given architectuire it might be
_illegal_ to map certain address ranges as write-combining without
checks like the ones above that ia64 needs.

Therefore your proposed interface is by definition insufficient.
