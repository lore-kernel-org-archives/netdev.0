From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/3] net: ti: netcp: restore get/set_pad_info() functionality
Date: Fri, 19 Feb 2016 21:56:14 +0100
Message-ID: <8660259.RH6vgAvune@wuerfel>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com> <1455904724-17952-2-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455904724-17952-2-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 12:58:42 Murali Karicheri wrote:
> The commit 899077791403 ("netcp: try to reduce type confusion in
> descriptors") introduces a regression in Kernel 4.5-rc1 and it breaks
> get/set_pad_info() functionality.
> 
> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
> store DMA/MEM buffer pointer and buffer size respectively. And in both
> cases for Keystone 2 the pointer type size is 32 bit regardless of
> LAPE enabled or not, because CONFIG_ARCH_DMA_ADDR_T_64BIT originally
> is not expected to be defined.
> 
> Unfortunately, above commit changed buffer's pointers save/restore
> code (get/set_pad_info()) and added intermediate conversation to u64
> which works incorrectly on 32bit Keystone 2 and causes TI NETCP driver
> crash in RX/TX path due to "Unable to handle kernel NULL pointer"
> exception. This issue was reported and discussed in [1].
> 
> Hence, fix it by partially reverting above commit and restoring
> get/set_pad_info() functionality as it was before.
> 
> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95361.html
> Cc: Wingman Kwok <w-kwok2@ti.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> CC: Arnd Bergmann <arnd@arndb.de>
> Reported-by: Franklin S Cooper Jr <fcooper@ti.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
