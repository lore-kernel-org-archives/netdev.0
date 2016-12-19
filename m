From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) netdev
Date: Sun, 18 Dec 2016 22:43:03 -0800
Message-ID: <20161219064303.GA94834@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215170109.GC3264@obsidianresearch.com>
 <20161216025947.GC90951@knc-06.sc.intel.com>
 <20161216042420.GB3797@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161216042420.GB3797-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 09:24:20PM -0700, Jason Gunthorpe wrote:
>> >>+struct __hfi_vesw_info {
>> >>+	u16  fabric_id;
>> >>+	u16  vesw_id;
>> >>+
>> >>+	u8   rsvd0[6];
>> >>+	u16  def_port_mask;
>> >>+
>> >>+	u8   rsvd1[2];
>> >>+	u16  pkey;
>> >>+
>> >>+	u8   rsvd2[4];
>> >>+	u32  u_mcast_dlid;
>> >>+	u32  u_ucast_dlid[HFI_VESW_MAX_NUM_DEF_PORT];
>> >>+
>> >>+	u8   rsvd3[44];
>> >>+	u16  eth_mtu[HFI_VNIC_MAX_NUM_PCP];
>> >>+	u16  eth_mtu_non_vlan;
>> >>+	u8   rsvd4[2];
>> >>+} __packed;
>> >
>> >This goes on the network too? Also looks like it has endian problems.
>> >
>> >Ditto for all the __packed structures.
>> >
>>
>> This is in CPU format. There is a separate big endian version of
>> this
>
>Why are CPU handled structures packed and full of reserved fields?
>Don't pack them if they are not pushed out to the network..
>
>There were lots of __packed structures, any that go on the network
>need be/le annoations.
>

Well, driver treats the reserved fields to be sticky. ie., information
block returned (upon GET) to EM is not changed (from SET) except few fields 
which driver is expected to modify.
Structures that go on wire are big endian __packed structures in 
hfi_vnic_encap.h. Ok, I will remove the __packed attribute from CPU handled 
structures here.

Niranjana

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
