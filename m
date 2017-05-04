From: Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 15:26:13 -0400
Message-ID: <2dee6cde-0406-b101-0fe6-c1f6de7c1b1a@intel.com>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
 <20170504182542.GD22833@mtr-leonro.local>
 <1493922625.2692.8.camel@sandisk.com>
 <20170504184531.GE22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jiri@mellanox.com" <jiri@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ram.amrani@cavium.com" <ram.amrani@cavium.com>,
        "sagi@grimberg.me" <sagi@grimberg.me>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "hch@lst.de" <hch@lst.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17644 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750865AbdEDT0R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 15:26:17 -0400
In-Reply-To: <20170504184531.GE22833@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2017 02:45 PM, Leon Romanovsky wrote:
> On Thu, May 04, 2017 at 06:30:27PM +0000, Bart Van Assche wrote:
>> On Thu, 2017-05-04 at 21:25 +0300, Leon Romanovsky wrote:
>>> On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche wrote:
>>>> On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
>>>>> Following our discussion both in mailing list [1] and at the LPC 2016 [2],
>>>>> we would like to propose this RDMA tool to be part of iproute2 package
>>>>> and finally improve this situation.
>>>>
>>>> Hello Leon,
>>>>
>>>> Although I really appreciate your work: can you clarify why you would like to
>>>> add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
>>>> for adding RDMA functionality to iproute2 in [1].
>>>
>>> We are planning to reuse the same infrastructure provided by iproute2,
>>> like netlink parsing, access to distributions, same CLI and same standards.
>>>
>>> Right now, RDMA is already tightened to netdev: iWARP, RoCE, IPoIB, HFI-VNIC.
>>> Many drivers (mlx, qed, i40, cxgb) are sharing code between net and
>>> RDMA.
>>>
>>> I do expect that iproute2 will be installed on every machine with any
>>> type of connection, including IB and OPA.
>>>
>>> So I think that it is enough to be part of that suite and don't invent
>>> our own for one specific tool.
>>
>> Hello Leon,
>>
>> Sorry but to me that sounds like a weak argument for including RDMA functionality
>> in iproute2. There is already a library for communication over netlink sockets,
>> namely libnl. Is there functionality that is in iproute2 but not in libnl and
>> that is needed for the new tool? If so, have you considered to create a new
>> library for that functionality?
>
> It is not hard to create new tool, the hardest part is to ensure that it is
> part of the distributions. Did you count how many months we are trying to
> add rdma-core to debian?

I do agree that it is a strange pairing and am not really a fan. However 
at the end of the day it's just a name for a repo/package. If the 
iproute folks are fine to include rdma in their repo/package, great we 
can leverage their code for CLI and other common stuff.

Now if the interface was something like "ip -FlagForRdma ..." I would 
object to that, but the interface is "rdma ... " so from users 
perspective it's different tools. They don't need to care that it was 
sourced from a common git repo.

Just as an aside this already works a bit with OPA:

  $ ./rdma link
1/1: hfi1_0/1: ifname NONE cap_mask 0x00410022 lid 0x1 lid_mask_count 0 
link_layer InfiniBand
          phys_state 5: LinkUp rate 100 Gb/sec (4X EDR) sm_lid 0x1 sm_sl 
0 state 4: ACTIVE

Leon I'll get you more feedback and testing, I've just been really 
bogged down this week, sorry.

-Denny
