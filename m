From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 09:14:44 -0700
Message-ID: <20101007091444.7a2e95d4@nehalam>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <Vijay_Nijhawan@Dell.com>,
	<Charles_Rose@Dell.com>
To: <Narendra_K@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2010 07:23:35 -0700
<Narendra_K@Dell.com> wrote:

> Hello,
> 
> V1 -> V2:
> 
> This patch addresses the scenario of buggy firmware/BIOS tables. The
> patch introduces a command line parameter 'no_netfwindex', passing which
> firmware provided index will not be used to derive 'eth' names. By
> default, firmware index will be used and the parameter can be used to
> work around buggy firmware/BIOS tables.
> 
> Please find the patch below.
> 
> From: Narendra K <narendra_k@dell.com>
> Subject: [PATCH] Use firmware provided index to register a network device
> 
> This patch uses the firmware provided index to derive the ethN name.
> If the firmware provides an index for the corresponding pdev, the N
> is derived from the index.
> 
> As an example, consider a PowerEdge R710 which has 4 BCM5709
> Lan-On-Motherboard ports,1 Intel 82572EI port and 4 82575GB ports.
> The system firmware communicates the order of the 4 Lan-On-Motherboard
> ports by assigning indexes to each one of them. This is available to
> the OS as the SMBIOS type 41 record(for onboard devices), in the field
> 'device type index'. It looks like below -

I agree with Greg. Provide the firmware index in sysfs for use
in udev userspace and let udev do the policy on the naming.
The firmware index could be missing, wrong, or interesting on only
some devices.
