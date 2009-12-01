From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Mon, 30 Nov 2009 17:03:25 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F12C7400AD3@orsmsx501.amr.corp.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
 <20091129.234037.232627669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mcarlson@broadcom.com" <mcarlson@broadcom.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"sathyap@serverengines.com" <sathyap@serverengines.com>,
	"subbus@serverengines.com" <subbus@serverengines.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26903 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbZLABD2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 20:03:28 -0500
In-Reply-To: <20091129.234037.232627669.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Tue, 24 Nov 2009 17:20:12 -0800
> 
>> This patch series removes the skb_dma_map and skb_dma_unmap function
>> calls. The reason for this change is because the use of
>> skb_dma_map/unmap can lead to serious issues when HW IOMMU is
>> enabled.  This is because each mapping 
>> of the skb with a HW IOMMU enabled results in a new set of DMA
>> mappings. 
>> This in turn leads to issues when skbs are cloned for uses such as
>> bridging or pktgen because each transmitting device will update the
>> skb shared info structure resulting in some mappings being
>> overwritten, and others being freed multiple times. 
>> 
>> I am looking for input specifically on the tg3, be2net, and bnx2
>> driver patches as I am not very familiar with them and I am not
>> certain if additional changes are required.
>> 
>> I have included the changes for the Intel wired Ethernet drivers as a
>> reference.
> 
> These changes look good, but at least one of them does not apply
> to current net-2.6
> 
> Can you respin this against current sources?
> 
> Thanks a lot for doing this work Alexander.

Due to the fact that nobody else had reported the issue and it existed in previous kernel versions I figured it would be easier to just drop it into net-next-2.6.

If you want I can change the patches to net-2.6 though if that is what you would prefer.

Thanks,

Alex