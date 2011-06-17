From: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [BUG] b43 / ssb: kernel BUG() in __queue_work()
Date: Fri, 17 Jun 2011 18:17:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1106171813420.27141@axis700.grange>
References: <Pine.LNX.4.64.1106171602330.27141@axis700.grange>
 <20110617144231.GB2528@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110617144231.GB2528-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Jun 2011, John W. Linville wrote:

> You probably should send this to linux-wireless-u79uwXL29TaiAVqoAR/hOK1cXZ9k6wlg@public.gmane.org

Thanks for forwarding, John. A short update: I verified back to 2.6.38(.5) 
and the bug is there too. It's even easier to reproduce with some more 
intensive IO, e.g., ssh to the system and run something like "top."

Thanks
Guennadi

> 
> On Fri, Jun 17, 2011 at 04:08:04PM +0200, Guennadi Liakhovetski wrote:
> > Hi
> > 
> > I'm getting reproducibly the below BUG() with recent kernels, e.g., next 
> > of today. Occurs on ARM and SuperH with an SDIO b43 card. Using WPA2, 
> > configure a network and start ping from outside, within a couple of 
> > minutes (usually under 1 minute actually) the kernel crashes.
> > 
> > Thanks
> > Guennadi
> > ---
> > Guennadi Liakhovetski, Ph.D.
> > Freelance Open-Source Software Developer
> > http://www.open-technology.de/
> > 
> > [  155.912000] ------------[ cut here ]------------
> > [  155.912000] kernel BUG at /home/lyakh/software/project/24/src/linux-2.6/kernel/workqueue.c:1037!
> > [  155.912000] Kernel BUG: 003e [#1]
> > [  155.912000] Modules linked in: aes_generic arc4 mmc_block b43 ssb mac80211 cfg80211 sh_mobile_sdhi tmio_mmc_core mmc_core sh_mobile_ceu_camera videobuf2_dma_contig videobuf2_memops soc_camera videobuf_core videobuf2_core v4l2_common uio_pdrv_genirq videodev uio soc_mediabus shdma
> > [  155.912000] 
> > [  155.912000] Pid : 1540, Comm: 		ksdioirqd/mmc0
> > [  155.912000] CPU : 0        		Not tainted  (3.0.0-rc3-ecovec+ #332)
> > [  155.912000] 
> > [  155.912000] PC is at __queue_work+0x1de/0x2ac
> > [  155.912000] PR is at __queue_work+0x1d2/0x2ac
> > [  155.912000] PC  : 8802a5fa SP  : 8d3719b0 SR  : 400081f0 TEA : c000e6e0
> > [  155.912000] R0  : 8d565000 R1  : 8d318f80 R2  : 8d565054 R3  : 00000000
> > [  155.912000] R4  : 8d565000 R5  : 8d68ef00 R6  : 8d318f7c R7  : 000005a0
> > [  155.912000] R8  : 8d318f7c R9  : 8d68ef00 R10 : 00000000 R11 : 8838e458
> > [  155.912000] R12 : 8d68d20c R13 : 00000000 R14 : 8d3719b0
> > [  155.912000] MACH: 00000064 MACL: 00000000 GBR : 00000000 PR  : 8802a5ee
> > [  155.912000] 
> > [  155.912000] Call trace:
> > [  155.912000]  [<c0294820>] ieee80211_duration+0x0/0x16c [mac80211]
> > [  155.912000]  [<8802a6e8>] queue_work_on+0x20/0x30
> > [  155.912000]  [<880036b4>] arch_local_irq_restore+0x0/0x2a
> > [  155.912000]  [<8802b53c>] queue_work+0x24/0x60
> > [  155.912000]  [<c0298904>] ieee80211_queue_work+0x20/0x34 [mac80211]
> > [  155.912000]  [<c02f512c>] b43_op_tx+0x40/0x5c [b43]
> > [  155.912000]  [<c029442e>] __ieee80211_tx+0x16e/0x1c0 [mac80211]
> > [  155.912000]  [<c029599e>] ieee80211_tx+0x76/0xc8 [mac80211]
> > [  155.912000]  [<c0295b4a>] ieee80211_xmit+0x15a/0x1b8 [mac80211]
> > [  155.912000]  [<88011efc>] sub_preempt_count+0x0/0x8c
> > [  155.912000]  [<881e0600>] skb_push+0x0/0x64
> > [  155.912000]  [<c0296a02>] ieee80211_subif_start_xmit+0x50e/0x55c [mac80211]
> > [  155.912000]  [<881e0600>] skb_push+0x0/0x64
> > [  155.912000]  [<881302b4>] memcpy+0x0/0x28c
> > [  155.912000]  [<881e85c2>] dev_hard_start_xmit+0x38a/0x49c
> > [  155.912000]  [<882034b6>] __ip_append_data+0x3da/0x6c4
> > [  155.912000]  [<881f8488>] sch_direct_xmit+0x60/0x1c0
> > [  155.912000]  [<881e88ac>] dev_queue_xmit+0x1d8/0x3f0
> > [  155.912000]  [<882053dc>] ip_finish_output+0x268/0x2b4
> > [  155.912000]  [<881302b4>] memcpy+0x0/0x28c
> > [  155.912000]  [<882054ae>] ip_output+0x86/0xac
> > [  155.912000]  [<88202e7c>] ip_local_out+0x5c/0x64
> > [  155.912000]  [<88202e90>] ip_send_skb+0xc/0x88
> > [  155.912000]  [<88203c52>] ip_push_pending_frames+0x22/0x38
> > [  155.912000]  [<88222856>] icmp_push_reply+0xce/0x104
> > [  155.912000]  [<88222a36>] icmp_reply+0x14a/0x1bc
> > [  155.912000]  [<88222bc6>] icmp_echo+0x3a/0x50
> > [  155.912000]  [<8821db68>] raw_local_deliver+0x0/0x1bc
> > [  155.912000]  [<8821db68>] raw_local_deliver+0x0/0x1bc
> > [  155.912000]  [<881e2b40>] __skb_checksum_complete+0x10/0x1c
> > [  155.912000]  [<88223050>] icmp_rcv+0xec/0x128
> > [  155.912000]  [<88200dee>] ip_local_deliver+0x86/0x13c
> > [  155.912000]  [<88200ce8>] ip_rcv+0x3d8/0x458
> > [  155.912000]  [<881e61d4>] __netif_receive_skb+0x298/0x2fc
> > [  155.912000]  [<881e636a>] netif_receive_skb+0x36/0x50
> > [  155.912000]  [<c02914f2>] ieee80211_deliver_skb+0xf6/0x158 [mac80211]
> > [  155.912000]  [<c02928a0>] ieee80211_rx_handlers+0xe16/0x124e [mac80211]
> > [  155.912000]  [<c01cff02>] mmc_wait_for_req+0xa6/0xd0 [mmc_core]
> > [  155.912000]  [<c01d59ca>] mmc_io_rw_extended+0x12a/0x1b0 [mmc_core]
> > [  155.912000]  [<881dff72>] skb_queue_tail+0x3e/0x74
> > [  155.912000]  [<c02933c0>] ieee80211_prepare_and_rx_handle+0x6e8/0x77c [mac80211]
> > [  155.912000]  [<c0293bda>] ieee80211_rx+0x786/0x818 [mac80211]
> > [  155.912000]  [<c01d0450>] mmc_wait_done+0x0/0x18 [mmc_core]
> > [  155.912000]  [<c0304e56>] b43_rx+0x4a2/0x510 [b43]
> > [  155.912000]  [<c030a6d6>] b43_pio_rx+0x2d6/0x35c [b43]
> > [  155.912000]  [<c02f864c>] b43_do_interrupt_thread+0x5b4/0x758 [b43]
> > [  155.912000]  [<c02f8852>] b43_sdio_interrupt_handler+0x26/0x48 [b43]
> > [  155.912000]  [<c030b370>] b43_sdio_interrupt_dispatcher+0x30/0x54 [b43]
> > [  155.912000]  [<c01d7368>] sdio_irq_thread+0x7c/0x274 [mmc_core]
> > [  155.912000]  [<c01d72ec>] sdio_irq_thread+0x0/0x274 [mmc_core]
> > [  155.912000]  [<8802f172>] kthread+0x4a/0x7c
> > [  155.912000]  [<8802f184>] kthread+0x5c/0x7c
> > [  155.912000]  [<c01d72ec>] sdio_irq_thread+0x0/0x274 [mmc_core]
> > [  155.912000]  [<88003d5c>] kernel_thread_helper+0x8/0x14
> > [  155.912000]  [<8802f128>] kthread+0x0/0x7c
> > [  155.912000]  [<88003d54>] kernel_thread_helper+0x0/0x14
> > [  155.912000] 
> > [  155.912000] Code:
> > [  155.912000]   8802a5f4:  cmp/eq    r1, r2
> > [  155.912000]   8802a5f6:  bt.s      8802a5fc
> > [  155.912000]   8802a5f8:  mov       r0, r4
> > [  155.912000] ->8802a5fa:  trapa     #62
> > [  155.912000]   8802a5fc:  mov.l     @(8,r4), r7
> > [  155.912000]   8802a5fe:  mov       r7, r1
> > [  155.912000]   8802a600:  add       #4, r1
> > [  155.912000]   8802a602:  shll2     r1
> > [  155.912000]   8802a604:  add       r4, r1
> > [  155.912000] 
> > [  155.912000] Process: ksdioirqd/mmc0 (pid: 1540, stack limit = 8d370001)
> > [  155.912000] Stack: (0x8d3719b0 to 0x8d372000)
> > [  155.912000] 19a0:                                     c0294820 8802a6e8 8d3719d4 00000000 
> > [  155.912000] 19c0: 8d68d20c 880036b4 8d68d000 8d68ef00 8d318f7c 8802b53c 8d3719dc c0298904 
> > [  155.912000] 19e0: 8d3719ec 8d371a38 8d31833c 8d318f7c c02f512c 8d3719fc 8d318ea0 c029442e 
> > [  155.912000] 1a00: 8d371a08 8d3182c0 00000000 00000000 8d339ae0 00000000 c029599e 8d371a38 
> > [  155.912000] 1a20: 8d506850 8f1e13c0 00000000 8d3182c0 8d339afc 8d339ae0 8d339ae0 8d3182c0 
> > [  155.912000] 1a40: 8f1e13c0 8d68d000 8d2e9200 c03123c0 00000800 00000002 c0295b4a 8d371a74 
> > [  155.912000] 1a60: 000003bc 88011efc 8d3182c0 8f1e13c0 8d339ae0 881e0600 8d339af8 8d371aa0 
> > [  155.912000] 1a80: c0296a02 8d371aa0 8d506850 881e0600 881302b4 8d506864 8f1e13c0 8d339ae0 
> > [  155.912000] 1aa0: 00000000 0000000c 0000001c 8d506850 8d506864 8d506842 8d3182c0 c0236b98 
> > [  155.912000] 1ac0: 8f1e1000 01081ad8 24000000 a5f335fe 02100e00 0200b772 0ece6872 8d370000 
> > [  155.912000] 1ae0: 8d2ecf20 881e85c2 8d371b04 8834278c 8f1e1000 8d68eea0 8834276c 00006000 
> > [  155.912000] 1b00: 8d339ae0 00000000 882034b6 c029b384 8834278c 881f8488 8d371b34 8d68eea0 
> > [  155.912000] 1b20: 00000010 8d68eea0 8f1e1000 8d2ed600 8d339ae0 881e88ac 8d371b54 8d2ed640 
> > [  155.912000] 1b40: 00000000 8d2ed600 8f1e1000 8d339ae0 8d2ed65c 882053dc 8d371b74 8d2bd74a 
> > [  155.912000] 1b60: 8d339b5c 00000000 0000000e 8d2bd740 8d339ae0 881302b4 fffffff0 8d2bd754 
> > [  155.912000] 1b80: 8d2bd750 882054ae 8d371ba4 8834270c 8d371bec 8d506866 8d339b20 8f1e1000 
> > [  155.912000] 1ba0: 8d339ae0 88202e7c 8d371bb4 8d371c38 8f0b5b80 88202e90 8d371bbc 88203c52 
> > [  155.912000] 1bc0: 8d371bc8 8f0b5b80 88222856 8d371bd0 88222a36 8d371bec 00000008 8d371be0 
> > [  155.912000] 1be0: 8d2da75c 8d3738c0 8d371c38 00000000 00000000 00000000 00010000 00000000 
> > [  155.912000] 1c00: 15b2a8c0 1bb2a8c0 00000000 15b2a8c0 00003810 00000000 c0349300 00000000 
> > [  155.912000] 1c20: 88222bc6 8d371c38 8821db68 88342bd8 8d373f01 3900a76f 8d2da6e0 00000000 
> > [  155.912000] 1c40: 00000038 00000000 3900a76f 15b2a8c0 00000200 00000100 00000008 0669ae33 
> > [  155.912000] 1c60: 00000000 00000000 00000000 00000000 8834270c 00000008 8821db68 88342bd8 
> > [  155.912000] 1c80: 8d2da720 8d2da6e0 881e2b40 8d371c9c 88342bd8 8d373f01 88223050 8d371ca4 
> > [  155.912000] 1ca0: 8d2da6e0 88200dee 8d371cb4 88342bdc 8d2da6e0 88200ce8 8d371ccc 00000000 
> > [  155.912000] 1cc0: 8d506c50 8d2da6f8 8d2da6e0 881e61d4 8d371ce4 00000000 8f1e1000 8d371cb4 
> > [  155.912000] 1ce0: 883426ec 0000009c 00000001 8d2da6e0 8834270c 881e636a 8d371d14 8f1e1000 
> > [  155.912000] 1d00: 8d2da6f8 8d3182c0 8d2da75c 00000000 8d2da6e0 8d2da6e0 c02914f2 8d371d20 
> > [  155.912000] 1d20: c02928a0 8d371d40 8f1e13c0 8f1e107c 8d3182c0 00000000 00004208 8d371dec 
> > [  155.912000] 1d40: 8d371dcc c01cff02 8d371d4c 00000000 8d371d50 00000000 c01d59ca 8d371d6c 
> > [  155.912000] 1d60: 00000004 8d371da0 8d43ec00 8d371de4 00000035 00000000 00001000 00001000 
> > [  155.912000] 1d80: 00005000 00001000 881dff72 c02933c0 8d371dac 8f1e177c 8d3182c0 8d2da6e0 
> > [  155.912000] 1da0: 8d506c28 0000002b 8d371dec 00000001 8d3182c0 8f1e13c0 c0293bda 8d371dd8 
> > [  155.912000] 1dc0: 8d2da6e0 8d371dec 8d68d000 00000000 8d68d000 8d3182c0 00000000 8d371d4c 
> > [  155.912000] 1de0: c01d0450 8d506c32 8d506c28 8d2da6e0 8d3182c0 8f1e13c0 8d68d000 8d2e9200 
> > [  155.912000] 1e00: 00000000 00000010 00000000 00000000 00000000 c0304e56 8d371e34 00007499 
> > [  155.912000] 1e20: 0000012a 00000002 8d2da6e0 8d3182c0 8d32f400 0000000f 00000002 00000000 
> > [  155.912000] 1e40: 8d2da720 8d506c22 8d2da75c 00000000 00000000 00000000 00000985 ffffffc7 
> > [  155.912000] 1e60: 00000000 0000000b 00000000 00000000 c030a6d6 8d371e90 8d32f400 0000008e 
> > [  155.912000] 1e80: 8d319009 8d2da75c 8d4ca424 8d4ca420 00000002 00000000 8d318ea0 8d2da6e0 
> > [  155.912000] 1ea0: 8d318f98 c02f864c 8d371ec4 00000001 8d3aa9bc 8d3aa93c 00010000 00008000 
> > [  155.912000] 1ec0: 8d32f400 8d32f000 00010000 00000000 00000000 00000000 00000000 00000000 
> > [  155.912000] 1ee0: 00008000 8d32f47c 8d32f400 c02f8852 8d371f0c 00000001 8d3aa9bc 8d3aa93c 
> > [  155.912000] 1f00: 8d32f400 8d32f400 8d318ea8 c030b370 8d371f1c 8d32f2fc 8d2e7000 c01d7368 
> > [  155.912000] 1f20: 8d371f30 8d43ec00 7fffffff 8d3aa800 8d4a5da4 c01d72ec 00000000 8d3aa8fc 
> > [  155.912000] 1f40: 8d3aaa44 00000003 00000001 8802f172 8802f184 8d371f70 00000000 00000000 
> > [  155.912000] 1f60: c01d72ec 8d3aa800 8d4a5d94 00000000 00000000 8d3aa800 00000000 8d371f7c 
> > [  155.912000] 1f80: 8d371f7c 88003d5c 8d371f9c 00000000 00000000 00000000 00000000 00000000 
> > [  155.912000] 1fa0: 00000000 00000000 00000000 00000000 00000000 8d4a5d94 8802f128 00000000 
> > [  155.912000] 1fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
> > [  155.912000] 1fe0: 8d371fa4 88003d54 00000000 40008000 00000000 00000000 00000000 00000000 
> > [  155.916000] ---[ end trace d5cca8a145e4559d ]---
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> 
> -- 
> John W. Linville		Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
> 

---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
