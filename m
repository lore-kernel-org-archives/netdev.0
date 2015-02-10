From: Yuwei Zheng <yuweizheng@139.com>
Subject: Re: [PATCH] ath9k_htc: add adaptive usb receive flow control to
 repair soft lockup with monitor mode
Date: Tue, 10 Feb 2015 08:36:10 +0800
Message-ID: <1423528570.19464.1.camel@am335x>
References: <1423506672-6686-1-git-send-email-yuweizheng@139.com>
	 <87oap0n6rv.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com,
	netdev@vger.kernel.org, zhengyuwei@360.cn
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9-42.mail.139.com ([221.176.9.42]:51478 "EHLO
	n9-42.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbbBKKI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 05:08:29 -0500
In-Reply-To: <87oap0n6rv.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On =E4=B8=89, 2015-02-11 at 11:20 +0200, Kalle Valo wrote:
> Yuwei Zheng <yuweizheng@139.com> writes:
>=20
> > The ath9k_hif_usb_rx_cb function excute on  the interrupt context, =
and ath9k_rx_tasklet excute
> > on the soft irq context. In other words, the ath9k_hif_usb_rx_cb ha=
ve more chance to excute than
> > ath9k_rx_tasklet.  So in the worst condition,  the rx.rxbuf receive=
 list is always full,
> > and the do {}while(true) loop will not be break. The kernel get a s=
oft lockup panic.=20
> > =20
> > [59011.007210] BUG: soft lockup - CPU#0 stuck for 23s!
> > [kworker/0:0:30609]
> > [59011.030560] BUG: scheduling while atomic: kworker/0:0/30609/0x40=
010100
> > [59013.804486] BUG: scheduling while atomic: kworker/0:0/30609/0x40=
010100
> > [59013.858522] Kernel panic - not syncing: softlockup: hung tasks
> > =20
> > [59014.038891] Exception stack(0xdf4bbc38 to 0xdf4bbc80)
> > [59014.046834] bc20:                                               =
        de57b950 60000113
> > [59014.059579] bc40: 00000000 bb32bb32 60000113 de57b948 de57b500 d=
c7bb440 df4bbcd0 00000000
> > [59014.072337] bc60: de57b950 60000113 df4bbcd0 df4bbc80 c04c259d c=
04c25a0 60000133 ffffffff
> > [59014.085233] [<c04c28db>] (__irq_svc+0x3b/0x5c) from [<c04c25a0>]=
 (_raw_spin_unlock_irqrestore+0xc/0x10)
> > [59014.100437] [<c04c25a0>] (_raw_spin_unlock_irqrestore+0xc/0x10) =
from [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_htc])
> > [59014.118267] [<bf9c2089>] (ath9k_rx_tasklet+0x290/0x490 [ath9k_ht=
c]) from [<c0036d23>] (tasklet_action+0x3b/0x98)
> > [59014.134132] [<c0036d23>] (tasklet_action+0x3b/0x98) from [<c0036=
709>] (__do_softirq+0x99/0x16c)
> > [59014.147784] [<c0036709>] (__do_softirq+0x99/0x16c) from [<c00369=
f7>] (irq_exit+0x5b/0x5c)
> > [59014.160653] [<c00369f7>] (irq_exit+0x5b/0x5c) from [<c000cfc3>] =
(handle_IRQ+0x37/0x78)
> > [59014.173124] [<c000cfc3>] (handle_IRQ+0x37/0x78) from [<c00085df>=
] (omap3_intc_handle_irq+0x5f/0x68)
> > [59014.187225] [<c00085df>] (omap3_intc_handle_irq+0x5f/0x68) from =
[<c04c28db>](__irq_svc+0x3b/0x5c)
> > =20
> > This bug can be see with low performance board, such as uniprocesso=
r beagle bone board. Add some debug message in the ath9k_hif_usb_rx_cb
> > function may trigger this bug quickly.
> > =20
> > Signed-off-by: Yuwei Zheng <yuweizheng@139.com>
>=20
> The word wrapping is still wrong, please limit the line length to 72
> chars or so. This is the second time I'm mentioning that. Also add v2=
,
> v3 and so on when you send new versions of the patch, otherwise I wil=
l
> not know what version I should use. And even better if you add a
> changelog after "---" line.
>=20
> Documentation/SubmittingPatches should tell you all this.
>=20

I have modified and resubmited as you suggest.
Thanks.
