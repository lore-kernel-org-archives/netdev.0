From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: set coherent DMA mask as well as streaming DMA
 mask
Date: Fri, 14 Oct 2016 22:48:47 +0200
Message-ID: <20161014204847.GA25285@electric-eye.fr.zoreil.com>
References: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42185 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753866AbcJNUs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 16:48:57 -0400
Content-Disposition: inline
In-Reply-To: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> :
> PCI devices that are 64-bit DMA capable should set the coherent
> DMA mask as well as the streaming DMA mask. On some architectures,
> these are managed separately, and so the coherent DMA mask will be
> left at its default value of 32 if it is not set explicitly. This
> results in errors such as
> 
>      r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>      hwdev DMA mask = 0x00000000ffffffff, dev_addr = 0x00000080fbfff000
>      swiotlb: coherent allocation failed for device 0000:02:00.0 size=4096
>      CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
>      Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016
> 
> on systems without memory that is 32-bit addressable by PCI devices.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Unless someone plans to plug an acenic, a 83820 (pci-e gem board, anyone ?)
on top of a pci <-> pci-e adapter on this kind of motherboard, no other
network driver that uses the pci_... dma api exhibits this mixed 32 / 64 bit
support bug. I haven't checked devices with 32 < mask < 64 nor plain DMA api
converted ones.

-- 
Ueimor
