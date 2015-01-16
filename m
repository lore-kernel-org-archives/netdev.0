From: Fabio Estevam <festevam@gmail.com>
Subject: Re: fec: warning found by dma debug
Date: Fri, 16 Jan 2015 09:32:20 -0200
Message-ID: <CAOMZO5Cj-b294AkybmU_n6Xfs5+QaVQ1=QkObM-oyUU8Zky19A@mail.gmail.com>
References: <CAH9NwWdR4mPz6c1Ce8tntWFMZXgO20Sgys8pvZwoGhjn6b7fnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Russell King <linux@arm.linux.org.uk>
To: Christian Gmeiner <christian.gmeiner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAH9NwWdR4mPz6c1Ce8tntWFMZXgO20Sgys8pvZwoGhjn6b7fnw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the report, Christian

Adding Andy and Russell on Cc.

On Fri, Jan 16, 2015 at 9:05 AM, Christian Gmeiner
<christian.gmeiner@gmail.com> wrote:
> [   17.946189] ------------[ cut here ]------------
> [   17.950848] WARNING: CPU: 0 PID: 3 at lib/dma-debug.c:1093
> check_unmap+0x858/0xa10()
> [   17.958674] fec 2188000.ethernet: DMA-API: device driver tries to
> free DMA memory it has not allocated [device
> address=0x0000000000000000] [size=34 bytes]
> [   17.972564] Modules linked in: etnaviv(C) imx_ipuv3_crtc imx_hdmi
> imxdrm drm_kms_helper drm
> [   17.981086] CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        WC
>  3.19.0-rc4+ #31
> [   17.988893] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [   17.995488] Backtrace:
> [   17.997982] [<c00135f0>] (dump_backtrace) from [<c0013948>]
> (show_stack+0x20/0x24)
> [   18.005609]  r6:c0883d40 r5:ffffffff r4:00000000 r3:dc8cb100
> [   18.011369] [<c0013928>] (show_stack) from [<c06a2ac0>]
> (dump_stack+0x78/0xc4)
> [   18.018683] [<c06a2a48>] (dump_stack) from [<c002c0a4>]
> (warn_slowpath_common+0x88/0xc4)
> [   18.026845]  r5:00000445 r4:e5205c80
> [   18.030479] [<c002c01c>] (warn_slowpath_common) from [<c002c19c>]
> (warn_slowpath_fmt+0x40/0x48)
> [   18.039231]  r8:00000000 r7:00000000 r6:00000022 r5:c0af9e18 r4:00000000
> [   18.046066] [<c002c160>] (warn_slowpath_fmt) from [<c038dc30>]
> (check_unmap+0x858/0xa10)
> [   18.054216]  r3:c089bb90 r2:c0884270
> [   18.057846] [<c038d3d8>] (check_unmap) from [<c038e0c4>]
> (debug_dma_unmap_page+0x80/0x88)
> [   18.066087]  r10:e38890c0 r9:00000000 r8:00000001 r7:00000001
> r6:e53f8850 r5:00000000
> [   18.074069]  r4:00000022
> [   18.076647] [<c038e044>] (debug_dma_unmap_page) from [<c045e368>]
> (fec_enet_rx_napi+0x7c0/0xb94)
> [   18.085494]  r8:00001400 r7:e795c780 r6:e389a0c0 r5:00000000 r4:00000000
> [   18.092349] [<c045dba8>] (fec_enet_rx_napi) from [<c053f14c>]
> (net_rx_action+0x130/0x568)
> [   18.100537]  r10:c0aefa80 r9:ffff91be r8:e5205e48 r7:00000040
> r6:0000012c r5:00000001
> [   18.108537]  r4:e38897b0
> [   18.111113] [<c053f01c>] (net_rx_action) from [<c0030768>]
> (__do_softirq+0x11c/0x794)
> [   18.118999]  r10:00000100 r9:c0053c58 r8:00000004 r7:c0b5ddac
> r6:00000008 r5:c0af208c
> [   18.127008]  r4:00000003
> [   18.129573] [<c003064c>] (__do_softirq) from [<c0030e20>]
> (run_ksoftirqd+0x40/0x6c)
> [   18.137291]  r10:00000000 r9:c0053c58 r8:c0b017cc r7:00000000
> r6:0000103c r5:e5157a00
> [   18.145298]  r4:00000001
> [   18.147878] [<c0030de0>] (run_ksoftirqd) from [<c0053de4>]
> (smpboot_thread_fn+0x1b0/0x354)
> [   18.156208] [<c0053c34>] (smpboot_thread_fn) from [<c004f114>]
> (kthread+0x104/0x128)
> [   18.164011]  r10:00000000 r9:00000000 r8:00000000 r7:c0053c34
> r6:e5157a00 r5:00000000
> [   18.172006]  r4:e5157800 r3:00000005
> [   18.175651] [<c004f010>] (kthread) from [<c000fc08>]
> (ret_from_fork+0x14/0x2c)
> [   18.182937]  r7:00000000 r6:00000000 r5:c004f010 r4:e5157800
> [   18.188680] ---[ end trace dcf0152c9771f20a ]---
>
> --
> Christian Gmeiner, MSc
>
> https://soundcloud.com/christian-gmeiner
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
