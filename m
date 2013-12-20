From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: error message: VF is not privileged to issue opcode 89-1
Date: Fri, 20 Dec 2013 08:35:21 -0800
Message-ID: <20131220083521.0000672d@unknown>
References: <52B41193.6020908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: vaughan <vaughan.cao@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45899 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755606Ab3LTQfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 11:35:24 -0500
In-Reply-To: <52B41193.6020908@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Dec 2013 17:44:51 +0800
vaughan <vaughan.cao@oracle.com> wrote:

> Hi experts,
> 
> I encounter the following error when creating SR-IOV VF for Emulex
> 10GB nic on 3.8.13 kernel.
> 
> # modprobe be2net num_vfs=4
>  be2net 0000:30:00.0: irq 214 for MSI/MSI-X
>  be2net 0000:30:00.0: enabled 1 MSI-x vector(s)
>  be2net 0000:30:00.0: created 0 RSS queue(s) and 1 default RX queue
>  be2net 0000:30:00.0: created 1 TX queue(s)
>  pci 0000:30:04.0: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:04.1: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:04.2: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:04.3: [19a2:0710] type 00 class 0x020000
>  be2net 0000:30:00.0: Emulex OneConnect(be3): PF  port 0
>  be2net 0000:30:00.1: irq 215 for MSI/MSI-X
>  be2net 0000:30:00.1: enabled 1 MSI-x vector(s)
>  be2net 0000:30:00.1: created 0 RSS queue(s) and 1 default RX queue
>  be2net 0000:30:00.1: created 1 TX queue(s)
>  pci 0000:30:06.0: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:06.1: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:06.2: [19a2:0710] type 00 class 0x020000
>  pci 0000:30:06.3: [19a2:0710] type 00 class 0x020000
>  be2net 0000:30:00.1: Emulex OneConnect(be3): PF  port 1
>  be2net 0000:30:04.0: enabling device (0140 -> 0142)
>  be2net 0000:30:04.0: Could not use PCIe error reporting
>  be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1
>  be2net 0000:30:04.0: VF is not privileged to issue opcode 125-1
>  be2net 0000:30:04.0: irq 216 for MSI/MSI-X
>  be2net 0000:30:04.0: enabled 1 MSI-x vector(s)
>  be2net 0000:30:04.0: created 0 RSS queue(s) and 1 default RX queue
>  be2net 0000:30:04.0: created 1 TX queue(s)
>  be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
>  be2net 0000:30:04.0: Exhausted multicast HW filters.
>  be2net 0000:30:04.0: Disabling HW multicast filtering.
>  be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
>  be2net 0000:30:04.0: Emulex OneConnect(be3): VF  port 0
> ...
> 
> But the module gets loaded and VFs are created.
> Also when the module is unloaded, below errors are seen in syslog:
>   be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1
> 
> I checked the code, this error occurs in be_probe() and the error
> opcode 89 is OPCODE_COMMON_SET_INTERRUPT_ENABLE, which is essential
> for an initializing process IMO. And I also found this thread
> https://lkml.org/lkml/2013/5/14/690, which shows there is a bug that
> VFs will be probed before PFs. According to this thread, I guess I may
> encountered the same error.
> Anyone can confirm if this is a real error like I guess? Thanks.
> 
> 

You might want to check the MAINTAINERS file and copy some of the folks
from emulex on this mail

SERVER ENGINES 10Gbps NIC - BladeEngine 2 DRIVER
M:      Sathya Perla <sathya.perla@emulex.com>
M:      Subbu Seetharaman <subbu.seetharaman@emulex.com>
M:      Ajit Khaparde <ajit.khaparde@emulex.com>
L:      netdev@vger.kernel.org
W:      http://www.emulex.com
S:      Supported
F:      drivers/net/ethernet/emulex/benet/

Just a suggestion.

In answer to your question - yes, it is possible for a VF to be probed
before the PF.  The drivers should handle that.

- Greg
