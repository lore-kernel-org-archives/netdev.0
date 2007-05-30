From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] Avoid switch on long long in s2io driver
Date: Wed, 30 May 2007 15:37:14 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701A70427@nekter>
References: <200705261904.09028.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Michael Buesch" <mb@bu3sch.de>, "Andreas Schwab" <schwab@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:34768 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758639AbXE3TxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 15:53:24 -0400
Content-class: urn:content-classes:message
In-Reply-To: <200705261904.09028.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch looks good. Yes, please add a comment as to reason for cast.

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Michael Buesch
> Sent: Saturday, May 26, 2007 10:04 AM
> To: Andreas Schwab
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] Avoid switch on long long in s2io driver
> 
> On Saturday 26 May 2007 10:58:15 Andreas Schwab wrote:
> > A switch on long long causes gcc to generate a reference to
__ucmpdi2 on
> > ppc32.  Avoid that by casting to int, since the value is only a
small
> > integer anyway.
> >
> > Signed-off-by: Andreas Schwab <schwab@suse.de>
> >
> > ---
> >  drivers/net/s2io.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > Index: linux-2.6.22-rc1/drivers/net/s2io.c
> > ===================================================================
> > --- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-13
> 11:03:28.000000000 +0200
> > +++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-13
12:52:49.000000000
> +0200
> > @@ -2898,7 +2898,7 @@ static void tx_intr_handler(struct fifo_
> >
> >  			/* update t_code statistics */
> >  			err >>= 48;
> > -			switch(err) {
> > +			switch((int)err) {
> 
> Hm, maybe add a comment, too?
> This cast looks redundant at the first look and someone
> who doesn't understand it might submit a patch to remove it again.
> 
> >  				case 2:
> >
nic->mac_control.stats_info->sw_stat.
> >
tx_buf_abort_cnt++;
> > @@ -6825,7 +6825,7 @@ static int rx_osm_handler(struct ring_in
> >
sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
> >  		}
> >  		err >>= 48;
> > -		switch(err) {
> > +		switch((int)err) {
> >  			case 1:
> >  				sp->mac_control.stats_info->sw_stat.
> >  				rx_parity_err_cnt++;
> >
> > Andreas.
> >
> 
> 
> 
> --
> Greetings Michael.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
