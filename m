From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 4 Nov 2011 17:24:46 +0000
Message-ID: <20111104172446.GB12913@n2100.arm.linux.org.uk>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com> <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Hamish Coleman <hamish@zot.apana.org.au>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:45038 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832Ab1KDRZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 13:25:12 -0400
Content-Disposition: inline
In-Reply-To: <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay, this is the only patch I saw (for the SEEQ drivers), but I notice
that more of the ARM drivers have moved.  The result is not nice.  Or
even workable.

While looking for my ether1, ether3 and etherh drivers in Kconfig, I
enable every option which is presented to me under the new 'ethernet
drivers' stuff.  I'm offered my ether3 driver under the SEEQ stuff -
that's fine.  But what about the rest?

Well...

drivers/net/ethernet/intel/Kconfig:
config NET_VENDOR_INTEL
        bool "Intel devices"
        default y
        depends on PCI || PCI_MSI

drivers/net/ethernet/i825xx/Kconfig:
config NET_VENDOR_I825XX
        bool "Intel (82586/82593/82596) devices"
        default y
        depends on NET_VENDOR_INTEL && (ISA || ISA_DMA_API || ARM || \
                   ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 || \
                   GSC || BVME6000 || MVME16x || EXPERIMENTAL)

if NET_VENDOR_I825XX
config ARM_ETHER1
        tristate "Acorn Ether1 support"
        depends on ARM && ARCH_ACORN

This is NOT a PCI driver, yet it has ended up with a requirement for
CONFIG_PCI to be set, which is nonsense for this platform because it
has no PCI.

What about etherh?
drivers/net/ethernet/natsemi/Kconfig:
config NET_VENDOR_NATSEMI
        bool "National Semi-conductor devices"
        default y
        depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT2000

drivers/net/ethernet/8390/Kconfig:
config NET_VENDOR_8390
        bool "National Semi-conductor 8390 devices"
        default y
        depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH || \
                   ISA || MCA || EISA || MAC || M32R || MACH_TX49XX || \
                   MCA_LEGACY || H8300 || ARM || MIPS || ZORRO || PCMCIA || \
                   EXPERIMENTAL)
if NET_VENDOR_8390
config ARM_ETHERH
        tristate "I-cubed EtherH/ANT EtherM support"
        depends on ARM && ARCH_ACORN

Again, exactly the same thing.

Thankfully, ARM_AM79C961A is right, so that's two out of five correct.

I've no idea what the right solution is to this complex maze of Kconfig
stuff.  Do I through an 'ARM' into the NET_VENDOR_INTEL and
NET_VENDOR_NATSEMI dependencies?

While I realise this is a big change, and bugs like this are likely, it
would've been nice to be copied on more of the patches which affect
drivers I maintain.
