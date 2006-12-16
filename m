From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: cxgb3 and 2.6.20-rc1
Date: Sat, 16 Dec 2006 20:12:55 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0612162007110.5411@yvahk01.tjqt.qr>
References: <4580E3D7.3050708@chelsio.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1283855629-71474371-1166296375=:5411"
Cc: Jeff Garzik <jeff@garzik.org>, torvalds@osdl.org, akpm@osdl.org,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161391AbWLPTRn@vger.kernel.org>
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <4580E3D7.3050708@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1283855629-71474371-1166296375=:5411
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Hi,


On Dec 13 2006 21:40, Divy Le Ray wrote:
>
> A corresponding monolithic patch is posted at the following URL:
> http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

I was unable to compile this on 2.6.20-rc1, because:

  CC [M]  drivers/net/cxgb3/cxgb3_offload.o
drivers/net/cxgb3/cxgb3_offload.c: In function ‘cxgb_free_mem’:
drivers/net/cxgb3/cxgb3_offload.c:1004: error: ‘PKMAP_BASE’ undeclared 
(first use in this function)

However, line 1004 is:

	if (p >= VMALLOC_START && p < VMALLOC_END)

and include/asm/pgtable.h:

	#ifdef CONFIG_HIGHMEM
	# define VMALLOC_END    (PKMAP_BASE-2*PAGE_SIZE)
	#else
	# define VMALLOC_END    (FIXADDR_START-2*PAGE_SIZE)
	#endif

So include/asm/pgtable.h lacks inclusion of include/asm/highmem.h,
where PKMAP_BASE is defined. Adding it gives me more compile errors.
Not good. Does anyone have a patch to fix that?


	-`J'
-- 
--1283855629-71474371-1166296375=:5411--
