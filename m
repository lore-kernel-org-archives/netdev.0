From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 1/2] pgtable: Add API to query if write
 combining is available
Date: Fri, 12 Dec 2014 15:36:44 -0500 (EST)
Message-ID: <20141212.153644.2158498939290171069.davem@davemloft.net>
References: <20141008.122450.1919301744382855426.davem@davemloft.net>
	<543A4FE4.7010807@dev.mellanox.co.il>
	<CAJ3xEMgufPhyeKHC_wWhw+khEhMAgG6yKuN8TLH0-xXH5Fq8Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: moshel@dev.mellanox.co.il, ogerlitz@mellanox.com,
	jackm@dev.mellanox.co.il, talal@mellanox.com,
	yevgenyp@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	moshel@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365AbaLLUgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 15:36:48 -0500
In-Reply-To: <CAJ3xEMgufPhyeKHC_wWhw+khEhMAgG6yKuN8TLH0-xXH5Fq8Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Thu, 27 Nov 2014 08:48:24 +0200

> On Sun, Oct 12, 2014 at 11:54 AM, Moshe Lazer <moshel@dev.mellanox.co.il> wrote:
>>
>> On 10/8/2014 7:24 PM, David Miller wrote:
>>>
>>> From: Moshe Lazer <moshel@dev.mellanox.co.il>
>>> Date: Wed, 08 Oct 2014 11:44:57 +0300
>>>
>>>>> #if defined(__i386__) || defined(__x86_64__)
>>>>>         if (map->type == _DRM_REGISTERS && !(map->flags &
>>>>> _DRM_WRITE_COMBINING))
>>>>>                 tmp = pgprot_noncached(tmp);
>>>>>         else
>>>>>                 tmp = pgprot_writecombine(tmp);
>>>>> #elif defined(__powerpc__)
>>>>>         pgprot_val(tmp) |= _PAGE_NO_CACHE;
>>>>>         if (map->type == _DRM_REGISTERS)
>>>>>                 pgprot_val(tmp) |= _PAGE_GUARDED;
>>>>> #elif defined(__ia64__)
>>>>>         if (efi_range_is_wc(vma->vm_start, vma->vm_end -
>>>>>                                     vma->vm_start))
>>>>>                 tmp = pgprot_writecombine(tmp);
>>>>>         else
>>>>>                 tmp = pgprot_noncached(tmp);
>>>>> #elif defined(__sparc__) || defined(__arm__) || defined(__mips__)
>>>>>         tmp = pgprot_noncached(tmp);
>>>>> #endif
>>>>
>>>> The idea was to provide an indication as for whether the arch supports
>>>> write-combining in general.
>>>> If we want to benefit from blue flame operations, we need to map the
>>>> blue flame registers as write combining - otherwise there is no
>>>> benefit. So we would like to know if write combining is supported by
>>>> the system or not.
>>>>
>>> You completely miss my point.  On a given architectuire it might be
>>> _illegal_ to map certain address ranges as write-combining without
>>> checks like the ones above that ia64 needs.
>>>
>>> Therefore your proposed interface is by definition insufficient.
>>
>> Thanks David, I'll try to clarify my point.
>> For me the writecombine_available() is a way to know if the
>> pgprot_writecombine() is effective or just cover call to the
>> pgprot_noncached().
>> I want to use the writecombine_available() regardless to the mapping
>> address.
>> For example in mlx4 query_device I want to indicate that blue-flame is not
>> supported if  `writecombine_available() ==  false`.
>> In this case we don't have the mapping address yet.
 ...
> Pinging you... could you respond on Moshe's email which hopefully
> addresses your comments?

As I stated, some platforms have restrictions on certain address ranges
when it comes to supporting write combining.

Therefore, it is a _requirement_, not optional, that we have an
address available so that the platform specific code can give an
accurate response to the question "is write combining available"
because the answer to that question is address dependent.
