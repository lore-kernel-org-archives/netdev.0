From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [GIT] Networking
Date: Thu, 14 Jan 2016 11:03:48 +0000
Message-ID: <56978094.4050302@arm.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
To: David Miller <davem@davemloft.net>,
	Hante Meuleman <meuleman@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112.215136.850414372508130298.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, Hante,

On 13/01/16 02:51, David Miller wrote:

[...]

> Hante Meuleman (33):
[...]
>       brcmfmac: Move all module parameters to one place

This particular patch breaks one of my boxes in a spectacular way:

[    3.602155] Unable to handle kernel paging request at virtual address 000027e4
[    3.602160] pgd = c0003000
[    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
[    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM
[    3.602187] Modules linked in:
[    3.602196] CPU: 0 PID: 4 Comm: kworker/0:0 Not tainted 4.4.0+ #5282
[    3.602199] Hardware name: Allwinner sun7i (A20) Family
[    3.602216] Workqueue: events_freezable mmc_rescan
[    3.602220] task: ee8f9140 ti: ee90a000 task.ti: ee90a000
[    3.602233] PC is at brcmf_ops_sdio_probe+0x260/0x380
[    3.602238] LR is at 0x1ff
[    3.602245] pc : [<c0437c54>]    lr : [<000001ff>]    psr: 20000113
[    3.602245] sp : ee90be00  ip : 01000000  fp : c0b7a7a0
[    3.602248] r10: 00000000  r9 : 00000000  r8 : c0b3e7cc
[    3.602252] r7 : eeb4ec00  r6 : eeaf4a40  r5 : ee1a3800  r4 : ee1ec000
[    3.602256] r3 : 00000100  r2 : 00002000  r1 : 00000001  r0 : eeb4ed44
[    3.602262] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    3.602266] Control: 30c5387d  Table: 40003000  DAC: fffffffd
[    3.602271] Process kworker/0:0 (pid: 4, stack limit = 0xee90a218)
[    3.602275] Stack: (0xee90be00 to 0xee90c000)
[    3.602284] be00: c0ba17bc ee1a3808 c0ba17c4 00000000 c0b3e7cc c03871d4 00000000 ee90be50
[    3.602291] be20: c03873ec 00000001 c0ba1798 00000000 00000000 c03855b4 eea43470 eebf6d38
[    3.602299] be40: ee1a3808 c0b597a0 ee1a383c c0386fb8 ee1a3808 00000001 ee1a3810 ee1a3810
[    3.602307] be60: c0b597a0 ee1a3808 00000000 c03865ec ee1a3810 ee1a3808 eeb4fc08 c0384838
[    3.602315] be80: 00000001 c05813e8 eefe2f00 eeb4ec00 ee1a3800 ee1a3808 00000002 00000002
[    3.602322] bea0: eeb4fc00 eeb4fc00 00000000 c0568944 00000001 eeb4ec00 00000002 c0567e3c
[    3.602330] bec0: 00000000 ee90becb 00000000 20ffff00 eeb4edbc c07ff75c eeb4ec00 00061a80
[    3.602338] bee0: c07ff768 00000000 00000000 c055fcfc eeb4edbc ee83b480 00000008 eefc1840
[    3.602346] bf00: eefc5100 c0054278 eefc1858 eefc1858 c0ace100 eefc1840 ee83b498 00000008
[    3.602354] bf20: eefc1858 c0ace100 ee90a000 eefc1840 ee83b480 c00545c4 eefc19a8 00000000
[    3.602361] bf40: c0054584 00000000 ee839d80 ee83b480 c0054584 00000000 00000000 00000000
[    3.602369] bf60: 00000000 c0059990 00000000 00000000 00000000 ee83b480 00000000 00000000
[    3.602377] bf80: ee90bf80 ee90bf80 00000000 00000000 ee90bf90 ee90bf90 ee90bfac ee839d80
[    3.602385] bfa0: c00598ac 00000000 00000000 c0027948 00000000 00000000 00000000 00000000
[    3.602392] bfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    3.602399] bfe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[    3.602425] [<c0437c54>] (brcmf_ops_sdio_probe) from [<c03871d4>] (really_probe+0x1cc/0x26c)
[    3.602438] [<c03871d4>] (really_probe) from [<c03855b4>] (bus_for_each_drv+0x68/0x9c)
[    3.602449] [<c03855b4>] (bus_for_each_drv) from [<c0386fb8>] (__device_attach+0x94/0xd4)
[    3.602457] [<c0386fb8>] (__device_attach) from [<c03865ec>] (bus_probe_device+0x8c/0x94)
[    3.602467] [<c03865ec>] (bus_probe_device) from [<c0384838>] (device_add+0x3d8/0x550)
[    3.602478] [<c0384838>] (device_add) from [<c0568944>] (sdio_add_func+0x64/0x78)
[    3.602492] [<c0568944>] (sdio_add_func) from [<c0567e3c>] (mmc_attach_sdio+0x244/0x2c0)
[    3.602504] [<c0567e3c>] (mmc_attach_sdio) from [<c055fcfc>] (mmc_rescan+0x28c/0x354)
[    3.602515] [<c055fcfc>] (mmc_rescan) from [<c0054278>] (process_one_work+0x140/0x44c)
[    3.602526] [<c0054278>] (process_one_work) from [<c00545c4>] (worker_thread+0x40/0x4e4)
[    3.602536] [<c00545c4>] (worker_thread) from [<c0059990>] (kthread+0xe4/0xfc)
[    3.602549] [<c0059990>] (kthread) from [<c0027948>] (ret_from_fork+0x14/0x2c)

This is caused by this hunk:

@@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
 	if (!sdiodev->sg_support)
 		return;
 
-	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
+	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
+		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
 	nents += (nents >> 4) + 1;
 
 	WARN_ON(nents > sdiodev->max_segment_count);

were drvr->settings is NULL (as the settings allocation seems to be done
much later). The fix is not completely obvious to me (probably requires
pushing the call to brcmf_mp_device_attach() down into the various bus
specific functions). An alternative would be to restore the txglomsz
parameter as it was before and not rely on settings being allocated.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
