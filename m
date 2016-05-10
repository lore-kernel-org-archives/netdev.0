From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Tue, 10 May 2016 14:09:50 -0400 (EDT)
Message-ID: <20160510.140950.1692247585115860282.davem@davemloft.net>
References: <20160509.151429.403288621356878412.davem@davemloft.net>
	<CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
	<CAKgT0UdvLpAxcCuNHZy6BJQyDiDOkpoJprjBXLM-43N5pGXOOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbcEJSJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:09:52 -0400
In-Reply-To: <CAKgT0UdvLpAxcCuNHZy6BJQyDiDOkpoJprjBXLM-43N5pGXOOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 10 May 2016 11:02:09 -0700

> On Tue, May 10, 2016 at 10:16 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>>  > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
>>> Date: Mon, 9 May 2016 16:19:10 +0300
>>>
>>> > +   /* bitmap indicating which fields hold valid values */
>>> > +   aligned_u64 valid_bitmap;
>>>
>>> There is absolutely no reason to use aligned_u64 here.  That type is for handling
>>> a specific issue in user facing APIs, which this is not.
>>
>> I'm not entirely convinced this is true; If we'll not enforce the alignment
>> of this 64-bit field, it's possible there will be differences between 32-bit
>> and 64-bit machines versions of this struct.
>> You have to recall that this is going to be copied via DMA between PF and VF,
>> so they must have the exact same representation of the structure.
>>
>> [If I'm wrong on the technical part here, please correct me; I vaguely
>> seem to recall that this was already discussed on bnx2x's implementation
>> of the hw-channel which also uses aligned u64 fields]
> 
> I think your change does have an impact, I just don't know if you
> really realize what it will get you.  Specifically what using the
> aligned_u64 is doing is forcing qed_bulletin_content to be u64 aligned
> and introducing two holes in qed_bulletin on 32 bit platforms where
> dma_addr_t might be 32 bit, and adding a 4 bytes of padding after
> size.

dma_addr_t is 32-bits on some 64-bit architectures too.
