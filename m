From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: Re: [PATCH net 6/6] bnx2x: Fix ethtool advertisement
Date: Wed, 7 Sep 2011 12:39:03 +0300
Message-ID: <1315388343.27750.3.camel@lb-tlvb-dmitry>
References: <1315291645.28564.20.camel@lb-tlvb-dmitry>
 <1315322392.2788.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4951 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756560Ab1IGQWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:22:00 -0400
In-Reply-To: <1315322392.2788.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 08:19 -0700, Ben Hutchings wrote:
> On Tue, 2011-09-06 at 09:47 +0300, Yaniv Rosner wrote:
> > Enable changing advertisement settings via ethtool and fix
> > flow-control advertisement when autoneg flow-control is disabled.
> [...]
> > diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> > index f74582a..42c7be1 100644
> > --- a/drivers/net/bnx2x/bnx2x_main.c
> > +++ b/drivers/net/bnx2x/bnx2x_main.c
> > @@ -2125,6 +2125,12 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
> >  void bnx2x_calc_fc_adv(struct bnx2x *bp)
> >  {
> >  	u8 cfg_idx = bnx2x_get_link_cfg_idx(bp);
> > +	if (bp->link_params.req_flow_ctrl[cfg_idx] != BNX2X_FLOW_CTRL_AUTO) {
> > +		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
> > +						   ADVERTISED_Pause);
> > +		return;
> > +	}
> [...]
> 
> I think you should still advertise the flow control behaviour you want,
> even if you will override the result of autonegotiation.
> 
> Ben.
> 
Ben,
It's a gray area, so I don't have a strong opinion this way or another.
I trust your senses, and will follow your suggestion to fix it.
Thanks,
Yaniv
