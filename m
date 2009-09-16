From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next]atl1e:fix 2.6.31-git4 -- ATL1E 0000:03:00.0:
 DMA-API: device driver frees DMA
Date: Tue, 15 Sep 2009 23:57:21 -0700 (PDT)
Message-ID: <20090915.235721.252164710.davem@davemloft.net>
References: <12530821133392-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miles.lane@gmail.com, chris.snook@gmail.com, jcliburn@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757343AbZIPG5J@vger.kernel.org>
In-Reply-To: <12530821133392-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Wed, 16 Sep 2009 14:21:53 +0800

> 
> [   25.059969] WARNING: at lib/dma-debug.c:816 check_unmap+0x383/0x55c()
> [   25.059976] Hardware name: 1000HE
> [   25.059984] ATL1E 0000:03:00.0: DMA-API: device driver frees DMA
>     memory with wrong function [device address=0x0000000036b92802] 
>     [size=90 bytes] [mapped as single] [unmapped as page]
> 
> use the wrong API when free dma. So when map dma use a flag to demostrate
> whether it is 'pci_map_single' or 'pci_map_page'. When free the dma, check
> the flags to select the right APIs('pci_unmap_single' or 'pci_unmap_page').
>  
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

An 'unsigned long' is an enormous type to use just to store
3 bits of information.  Use a u16 or similar to compact the
size of struct atl1e_tx_buffer

Also, it looks terribly ugle to define the flag macros, some with
three leading zeros in the hexadecimal values and one without.

Please make them consistent, thanks.

Generally, I see that this change was put together very hastily
and without very much care.
