From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH V4 2/3] can: m_can: update to support CAN FD features
Date: Tue, 18 Nov 2014 19:22:03 +0800
Message-ID: <20141118112201.GA28032@shlinux1.ap.freescale.net>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com>
 <1415349914-9145-2-git-send-email-b29396@freescale.com>
 <54648382.9080105@pengutronix.de> <5464E2D7.7010906@hartkopp.net>
 <5465CA47.4020802@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	<linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5465CA47.4020802@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 10:24:23AM +0100, Marc Kleine-Budde wrote:
> On 11/13/2014 05:56 PM, Oliver Hartkopp wrote:
> > On 11/13/2014 11:10 AM, Marc Kleine-Budde wrote:
> >> On 11/07/2014 09:45 AM, Dong Aisheng wrote:
> > 
> >>>  
> >>> -	if (id & RX_BUF_RTR) {
> >>> +	if (id & RX_BUF_ESI) {
> >>> +		cf->flags |= CANFD_ESI;
> >>> +		netdev_dbg(dev, "ESI Error\n");
> >>> +	}
> >>> +
> >>> +	if (!(dlc & RX_BUF_EDL) && (id & RX_BUF_RTR)) {
> >>>  		cf->can_id |= CAN_RTR_FLAG;
> >>
> >> I just noticed, that you don't set the cf->dlc (or cf->len) in the RTR
> >> case. Please create a separate patch that fixes this problem.
> >>
> >>>  	} else {
> >>>  		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> >>> -		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
> >>> -		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
> >>> -							 M_CAN_FIFO_DATA(0));
> >>> -		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
> >>> -							 M_CAN_FIFO_DATA(1));
> >>> +		if (dlc & RX_BUF_EDL)
> >>> +			cf->len = can_dlc2len((id >> 16) & 0x0F);
> >>> +		else
> >>> +			cf->len = get_can_dlc((id >> 16) & 0x0F);
> >>> +
> > 
> > Grr. I missed that one too :-(
> > 
> > Thanks for catching it.
> > 
> > As you committed patch 1 & 3 you expect a new single patch containing the
> > (fixed) content of this patch 2, right?
> 
> No, please make it two patches:
> 
> First the Bugfix: One setting the cf->dlc in the RTR case, too.
> Then the new feature: The other one adding CAN-FD support.
> 

Thanks for finding this.
Will do a patch soon as you said.

Regards
Dong Aisheng

> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 


