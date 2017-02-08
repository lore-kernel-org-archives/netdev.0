From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC v3 09/11] IB/hfi1: HFI_VNIC RDMA netdev support
Date: Wed, 8 Feb 2017 10:21:25 -0800
Message-ID: <20170208182125.GA77708@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-10-git-send-email-niranjana.vishwanathapura@intel.com>
 <VI1PR0502MB3008F059241234D3CD1BB587D1420@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "ira.weiny@intel.com" <ira.weiny@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: Parav Pandit <parav@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45562 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750966AbdBHSY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 13:24:27 -0500
Content-Disposition: inline
In-Reply-To: <VI1PR0502MB3008F059241234D3CD1BB587D1420@VI1PR0502MB3008.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:06:40AM +0000, Parav Pandit wrote:
>Hi,
>
>> -----Original Message-----
>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>> owner@vger.kernel.org] On Behalf Of Vishwanathapura, Niranjana
>> Sent: Tuesday, February 7, 2017 2:23 PM
>> To: dledford@redhat.com
>> Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org;
>> dennis.dalessandro@intel.com; ira.weiny@intel.com; Niranjana
>> Vishwanathapura <niranjana.vishwanathapura@intel.com>; Andrzej
>> Kacprowski <andrzej.kacprowski@intel.com>
>> Subject: [RFC v3 09/11] IB/hfi1: HFI_VNIC RDMA netdev support
>>
>> Add support to create and free HFI_VNIC rdma netdev devices.
>> Implement netstack interface functionality including xmit_skb, receive side
>> NAPI etc. Also implement rdma netdev control functions.
>>
>
>All code in this particular patch belong to netdev VNIC ULP driver.
>There is nothing much that appears specific to IB/RDMA that makes drivers/infiniband/hw as better place to be.
>It has netdev tx, rx, napi, stats in this patch.
>If VNIC is a ULP than most of the VNIC specific code should reside in the ULP directory or drivers/net/ethernet ?

This patch implements HW specific portion of VNIC netdev. As it turnes out HW 
queue spefific netstack interfacing (like NAPI, xmit_skb, Tx queue throttling 
etc) are specific to HW implementation of the queues. Netstack APIs are 
designed for that. Hence they belong in HW driver here and not in ULP.

The HFI_VNIC ULP, implements control plane operatings by tapping into control 
operations (open, close etc and encapsulation as specified by control plane).

Niranjana
