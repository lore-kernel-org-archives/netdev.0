From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Enable IOMMU pass through for
 be2net
Date: Thu, 13 Sep 2012 17:09:02 -0400 (EDT)
Message-ID: <20120913.170902.501405009717590679.davem@davemloft.net>
References: <1347472734-3196-1-git-send-email-craig.hada@hp.com>
	<4988B24899FF4448BF3D99EFCD2A3562323AD5@G1W3785.americas.hpqcorp.net>
	<505212A3.1030307@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org
To: craig.hada@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <505212A3.1030307@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Craig Hada <craig.hada@hp.com>
Date: Thu, 13 Sep 2012 10:06:43 -0700

> On 9/13/2012 9:27 AM, Hada, Craig M wrote:
>> This patch sets the coherent DMA mask to 64-bit after the be2net
>> driver has been acknowledged that the system is 64-bit DMA
>> capable. The coherent DMA mask is examined by the Intel IOMMU driver
>> to determine whether to allow pass through context mapping for all
>> devices. With this patch, the be2net driver combined with be2net
>> compatible hardware provides comparable performance to the case where
>> vt-d is disabled. The main use case for this change is to decrease the
>> time necessary to copy virtual machine memory during KVM live
>> migration instantiations.
>>
>> This patch was tested on a system that enables the IOMMU in
>> non-coherent mode. Two DMA remapper issues were encountered and both
>> are in the Intel IOMMU driver with the following patches submitted
>> upstream but not yet commited.
>>
>> Patch 1 - DMAR:[fault reason 02] Present bit in context entry is clear
>> https://lkml.org/lkml/2012/6/15/20
> 
> My apologies for posting a truncated link for the above. The correct
> link is https://lkml.org/lkml/2012/6/15/204

First of all you've made this email reply in such a way it didn't
get logged in the patch in patchwork, perhaps because either the
Message-Id got changed or flat-out removed, I can't say for sure.

Secondly, it is not appropriate to install a change that will
knowingly break usage of the device until the IOMMU reaper fixes
actually exist upstream.  This patch is absolutely dependent upon
those fixes, and therefore must only get applied to trees that
have the IOMMU fixes installed.

You must therefore wait for upstream to acquire the fixes, upstream to
get sync'd into the networking trees, and then you apply a patch with
these requirements.
