From: Tariq Toukan <tariqt@mellanox.com>
Subject: RE: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx ring
 for tx support
Date: Tue, 12 Jul 2016 12:09:56 +0000
Message-ID: <AM4PR05MB15533FAED9D659D3AE955878AE300@AM4PR05MB1553.eurprd05.prod.outlook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	"Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0072.outbound.protection.outlook.com ([104.47.1.72]:45600
	"EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750784AbcGMAjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 20:39:53 -0400
In-Reply-To: <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>The mlx4 driver by default allocates order-3 pages for the ring to consume in multiple fragments. When the device has an xdp program, this behavior will prevent tx actions since the page must be re-mapped in TODEVICE mode, which cannot be done if the page is still shared.
>
>Start by making the allocator configurable based on whether xdp is running, such that order-0 pages are always used and never shared.
>
>Since this will stress the page allocator, add a simple page cache to each rx ring. Pages in the cache are left dma-mapped, and in drop-only stress tests the page allocator is eliminated from the perf report.
>
>Note that setting an xdp program will now require the rings to be reconfigured.
>
>Before:
> 26.91%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
> 17.88%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_alloc_frags
>  6.00%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_frag
>  4.49%  ksoftirqd/0  [kernel.vmlinux]  [k] get_page_from_freelist
>  3.21%  swapper      [kernel.vmlinux]  [k] intel_idle
>  2.73%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
>  2.57%  swapper      [mlx4_en]         [k] mlx4_en_process_rx_cq
>
>After:
> 31.72%  swapper      [kernel.vmlinux]       [k] intel_idle
>  8.79%  swapper      [mlx4_en]              [k] mlx4_en_process_rx_cq
>  7.54%  swapper      [kernel.vmlinux]       [k] poll_idle
>  6.36%  swapper      [mlx4_core]            [k] mlx4_eq_int
>  4.21%  swapper      [kernel.vmlinux]       [k] tasklet_action
>  4.03%  swapper      [kernel.vmlinux]       [k] cpuidle_enter_state
>  3.43%  swapper      [mlx4_en]              [k] mlx4_en_prepare_rx_desc
>  2.18%  swapper      [kernel.vmlinux]       [k] native_irq_return_iret
>  1.37%  swapper      [kernel.vmlinux]       [k] menu_select
>  1.09%  swapper      [kernel.vmlinux]       [k] bpf_map_lookup_elem
>
>Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
