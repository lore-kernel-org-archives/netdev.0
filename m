From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 22 Nov 2016 16:53:18 -0800
Message-ID: <20161123005318.GA69897@knc-06.sc.intel.com>
References: <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161122194918.GA69241@knc-06.sc.intel.com>
 <alpine.DEB.2.20.1611221656390.8214@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:2278 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755568AbcKWBF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 20:05:29 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1611221656390.8214@east.gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 05:04:37PM -0600, Christoph Lameter wrote:
>On Tue, 22 Nov 2016, Vishwanathapura, Niranjana wrote:
>
>> Ok, I do understand Jason's point that we should probably not put this driver
>> under drivers/infiniband/sw/.., as this driver is not a HCA.
>> It is an ULP similar to ipoib, built on top of Omni-path irrespective of
>> whether we register a hfi_vnic_bus or a direct custom interface with HFI1.
>> This ULP will transmit and recieve Omni-path packets over the fabric, and is
>> dependent on IB MAD interface and the HFI1 driver.
>
>This is something that encapsulates IP (v4 right?) in something else.
>Would belong into
>
>	linux/net/ipv4
>
>You already have similar implementations there
>
>See f.e. ipip.c, ip_tunnel.c and lots more (try
>	ls linux/net/ipv4/*tunnel*
>
>)
>
>If this is more like a device then it would belong into
>
>linux/drivers/net/hfi or so (see also linux/drivers/net/ppp, plip,
>loopback, etc etc)
>

It is Ethernet packet encapsulated in Omni-path header by hfi_vnic driver.
The packets are sent and received over the wire by the HFI1 device driven by 
HFI1 driver. The encapsulation information is obtained via IB MAD control 
interface.

Niranjana

>
>
