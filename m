From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) netdev
Date: Thu, 15 Dec 2016 21:24:20 -0700
Message-ID: <20161216042420.GB3797@obsidianresearch.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215170109.GC3264@obsidianresearch.com>
 <20161216025947.GC90951@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, dennis.dalessandro@intel.com,
        ira.weiny@intel.com, Sadanand Warrier <sadanand.warrier@intel.com>,
        Sudeep Dutt <sudeep.dutt@intel.com>,
        Tanya K Jajodia <tanya.k.jajodia@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33626 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758849AbcLPEYb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 23:24:31 -0500
Content-Disposition: inline
In-Reply-To: <20161216025947.GC90951@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 06:59:47PM -0800, Vishwanathapura, Niranjana wrote:
> We have made the hfi_vnic driver dependent on CONFIG_X86_64.

Er, don't do that either?

> >>+struct __hfi_vesw_info {
> >>+	u16  fabric_id;
> >>+	u16  vesw_id;
> >>+
> >>+	u8   rsvd0[6];
> >>+	u16  def_port_mask;
> >>+
> >>+	u8   rsvd1[2];
> >>+	u16  pkey;
> >>+
> >>+	u8   rsvd2[4];
> >>+	u32  u_mcast_dlid;
> >>+	u32  u_ucast_dlid[HFI_VESW_MAX_NUM_DEF_PORT];
> >>+
> >>+	u8   rsvd3[44];
> >>+	u16  eth_mtu[HFI_VNIC_MAX_NUM_PCP];
> >>+	u16  eth_mtu_non_vlan;
> >>+	u8   rsvd4[2];
> >>+} __packed;
> >
> >This goes on the network too? Also looks like it has endian problems.
> >
> >Ditto for all the __packed structures.
> >
> 
> This is in CPU format. There is a separate big endian version of
> this

Why are CPU handled structures packed and full of reserved fields?
Don't pack them if they are not pushed out to the network..

There were lots of __packed structures, any that go on the network
need be/le annoations.

Jason
