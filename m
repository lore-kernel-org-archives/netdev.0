From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v1 1/4] net: ti: netcp: restore get/set_pad_info() functionality
Date: Fri, 19 Feb 2016 17:41:14 +0100
Message-ID: <15189559.iSkBKBkX2y@wuerfel>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com> <7111317.k6f7A38a4k@wuerfel> <56C7394E.50207@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C7394E.50207@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 10:48:30 Murali Karicheri wrote:
> On 02/19/2016 09:41 AM, Arnd Bergmann wrote:
> > On Thursday 18 February 2016 14:46:14 Murali Karicheri wrote:
> >> From: Arnd Bergmann <arnd@arndb.de>
> >>
> >> The commit 899077791403 ("netcp: try to reduce type confusion in
> >> descriptors") introduces a regression in Kernel 4.5-rc1 and it breaks
> >> get/set_pad_info() functionality.
> >>
> >> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
> >> store DMA/MEM buffer pointer and buffer size respectively. And in both
> >> cases for Keystone 2 the pointer type size is 32 bit regardless of
> >> LAPE enabled or not, because CONFIG_ARCH_DMA_ADDR_T_64BIT originally
> >> is not expected to be defined.
> >>
> >>                      !LAPE   LPAE
> >> sizeof(void*)                32bit   32bit
> >> sizeof(dma_addr_t)   32bit   32bit
> >> sizeof(phys_addr_t)  32bit   64bit
> > 
> > As this was never relevant or true, I don't think it needs to be
> > mentioned here, it just confuses things. Please just assume that
> > dma_addr_t can be 64-bit wide, but will only contain 32-bit
> > numbers on keystone.
> > 
> 
> I can remove this from the commit description and re-send.

Ok

> >> Unfortunately, above commit changed buffer's pointers save/restore
> >> code (get/set_pad_info()) and added intermediate conversation to u64
> >> which works incorrectly on 32bit Keystone 2 and causes TI NETCP driver
> >> crash in RX/TX path due to "Unable to handle kernel NULL pointer"
> >> exception. This issue was reported and discussed in [1].
> > 
> > Have you been able to figure out why it actually broke? I'd still
> > like to know.
> > 
> As Grygorii is out of office until Monday, I would like to step in.
> I will take some time today to try review the reverted changes for
> failure reason and get back. But as you have agreed in the discussion
> at https://www.mail-archive.com/netdev@vger.kernel.org/msg96311.html
> Can we fix the regression by applying this patch and rest of the series
> if it looks good? If I need to separate this from rest of the series,
> let me know and I can take care of that.

Yes, sounds fine.

> >> Hence, fix it by partially reverting above commit and restoring
> >> get/set_pad_info() functionality as it was before.
> >>
> >> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95361.html
> >> Cc: Wingman Kwok <w-kwok2@ti.com>
> >> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> >> CC: David Laight <David.Laight@ACULAB.COM>
> >> Reported-by: Franklin S Cooper Jr <fcooper@ti.com>
> >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> >> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> > 
> > I don't think I sent this patch with a 'Signed-off-by', did I?
> > (I could be misremembering that).
> > 
> 
> I think you had agreed based on what I read at
> https://www.mail-archive.com/netdev@vger.kernel.org/msg96311.html
> 
> reproduced below for your convenience.
> =============================================================================
> 
> > What I could do now is update your/my patch as i mentioned in [1]
> > and re-send it at the weekend (with your authorship and my signoff).
> > Do you agree?
> > 
> > 
> > [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg95831.html
> 
> Yes, let's do that in the meantime. I can also make sure that that
> the driver doesn't build on 64-bit, just in case.
> =============================================================================
> 
> Hope I can keep your sign-off when I re-send this. Please confirm.

The most important part here is that you don't add a "Signed-off-by"
tag unless it was provided by that person as part of the submission.

I'm slightly uncomfortable with having my Signed-off-by as the first
one when I did not write the changelog myself, so I'd prefer if
you just add my Acked-by once I provide that. If that doesn't
work for you, let's follow up in private to sort it out.

	Arnd
