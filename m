From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Tue, 10 May 2016 15:10:53 -0400 (EDT)
Message-ID: <20160510.151053.113553471670048412.davem@davemloft.net>
References: <CO2PR11MB00887DD775313A8DC3F39FA597710@CO2PR11MB0088.namprd11.prod.outlook.com>
	<20160510.140643.1891656073031893382.davem@davemloft.net>
	<CO2PR11MB0088ECDC1D7A65B703E2DDE797710@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbcEJTK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 15:10:56 -0400
In-Reply-To: <CO2PR11MB0088ECDC1D7A65B703E2DDE797710@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 10 May 2016 18:15:08 +0000

>> > I'm not entirely convinced this is true; If we'll not enforce the
>> > alignment of this 64-bit field, it's possible there will be
>> > differences between 32-bit and 64-bit machines versions of this struct.
>> > You have to recall that this is going to be copied via DMA between PF
>> > and VF, so they must have the exact same representation of the structure.
>> 
>> Then use properly sized types to fill in all the space in the structure, that's how
>> you guarantee layout, not aligned_u64.  Also, do not use the packed attribute.
>> 
>> struct foo {
>> 	u32 x;
>> 	u32 y;
>> 	u64 z;
>> };
>> 
>> 'z' will always be 64-bit aligned.
> 
> Perhaps my bit-numeric is a bit weak - why is it so?

foo is 64-bit aligned, therefore a properly aligned struct member will
be so as well.

We absolutely depend upon this for several data structures in the kernel.
