From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: bnx2x: link detected up at startup even when it should be
 down
Date: Thu, 27 Sep 2012 13:43:17 +0200
Message-ID: <1348746197.7217.49.camel@lb-tlvb-dmitry>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F3086A3@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
 <CAL8zT=j9LC5hKtmkzBA-Epa+NhX1YpC9RodJ-C+UunTH_HRVKQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F30910B@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=h31Prm2dpyKM8wwg_cb1a8_0yP2ziNzhNFC-3J1M0Khg@mail.gmail.com>
 <CAL8zT=i4tdneZVopZGtHVhMArGMH5n=BVrtkaNSVJPX=RtR6OQ@mail.gmail.com>
 <1348734095.7217.46.camel@lb-tlvb-dmitry>
 <CAL8zT=jFRJt5OT_nJWWocKjWJJ3LajKrA1f7Zy5wMKz9V-DHXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Jean-Michel Hautbois" <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1199 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab2I0LnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 07:43:06 -0400
In-Reply-To: <CAL8zT=jFRJt5OT_nJWWocKjWJJ3LajKrA1f7Zy5wMKz9V-DHXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 12:07 +0200, Jean-Michel Hautbois wrote:
> 2012/9/27 Dmitry Kravkov <dmitry@broadcom.com>:
> > On Tue, 2012-09-25 at 16:00 +0200, Jean-Michel Hautbois wrote:
> >> 2012/9/25 Jean-Michel Hautbois <jhautbois@gmail.com>:
> >> > 2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
> >> >>> -----Original Message-----
> >> >>> From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
> >> >>> Sent: Tuesday, September 25, 2012 2:54 PM
> >> >>> To: Dmitry Kravkov
> >> >>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
> >> >>> Subject: Re: bnx2x: link detected up at startup even when it should be down
> >> >>
> >> >>
> >> FYI, eth4 and eth5 are seen UP and they should be down.
> > It looks driver misses DCC "disable/enable" update
> >
> > Can you pls test this simple patch?
> >
> > From 1efa0314f4b912f474089f5f8375d37bc265a502 Mon Sep 17 00:00:00 2001
> > From: Dmitry Kravkov <dmitry@broadcom.com>
> > Date: Fri, 22 Mar 2013 05:12:02 +0200
> > Subject: [PATCH] bnx2x: DCC disable/enable update can be missed by driver
> >
> > As a result of missed update, OS may be updated with wrong link status.
> > ---
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> > index 2f6361e..3962d57 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> > @@ -3445,6 +3445,7 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
> >                         int func = BP_FUNC(bp);
> >
> >                         REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
> > +                       bnx2x_read_mf_cfg(bp);
> >                         bp->mf_config[BP_VN(bp)] = MF_CFG_RD(bp,
> >                                         func_mf_config[BP_ABS_FUNC(bp)].config);
> >                         val = SHMEM_RD(bp,
> > --
> > 1.7.1
> >
> >
> >
> >> JM
> >>
> 
> This patch does not work (no change at all).
> 

Since bnx2x.debug didn't work for you, Let's try to force some debug
messages from inside the driver:

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 3962d57..c6aeac0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10791,7 +10791,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 			  tx_count, rx_count);
 
 	bp->igu_sb_cnt = max_non_def_sbs;
-	bp->msg_enable = debug;
+	bp->msg_enable = debug | BNX2X_MSG_MCP | NETIF_MSG_PROBE | NETIF_MSG_LINK;
 	pci_set_drvdata(pdev, dev);
 
 	rc = bnx2x_init_dev(pdev, dev, ent->driver_data);
-- 
1.7.1

Can you post outputs then?

Thanks

> Regards,
> JM
> 
