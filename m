From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] tg3: shows HW time stamping support only if
 ptp_capable is present
Date: Tue, 30 Apr 2013 10:10:51 -0300
Message-ID: <20130430131051.GA19993@obelix.rh>
References: <1367255287-2664-1-git-send-email-fbl@redhat.com>
 <20130430105015.097b4b59@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760220Ab3D3NKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 09:10:54 -0400
Content-Disposition: inline
In-Reply-To: <20130430105015.097b4b59@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 10:50:15AM +0200, Jiri Benc wrote:
> On Mon, 29 Apr 2013 14:08:07 -0300, Flavio Leitner wrote:
> > Current tg3 shows hardware timestamping support for all devices
> > when that is true only for the hardware with PTP_CAPABLE flag
> > present.
> > 
> > Signed-off-by: Flavio Leitner <fbl@redhat.com>
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index ac83c87..ef0b8a6 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -5992,10 +5992,13 @@ static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
> >  
> >  	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
> >  				SOF_TIMESTAMPING_RX_SOFTWARE |
> > -				SOF_TIMESTAMPING_SOFTWARE    |
> > -				SOF_TIMESTAMPING_TX_HARDWARE |
> > -				SOF_TIMESTAMPING_RX_HARDWARE |
> > -				SOF_TIMESTAMPING_RAW_HARDWARE;
> > +				SOF_TIMESTAMPING_SOFTWARE;
> > +
> > +	if (tg3_flag(tp, PTP_CAPABLE)) {
> > +		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
>                                      ^^^^
>                          You need |= here.

Of course, I will send a follow up patch.
Thanks for reviewing it.
-- 
fbl
