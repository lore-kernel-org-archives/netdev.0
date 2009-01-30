From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: timeout reaches -1
Date: Thu, 29 Jan 2009 17:30:09 -0800 (PST)
Message-ID: <20090129.173009.230013997.davem@davemloft.net>
References: <4981C743.90202@gmail.com>
	<OF3A0B52EF.AB017C24-ON8025754D.00547404-8025754D.00548C02@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55242
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755717AbZA3BaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:30:11 -0500
In-Reply-To: <OF3A0B52EF.AB017C24-ON8025754D.00547404-8025754D.00548C02@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Thu, 29 Jan 2009 15:22:03 +0000

> Roel Kluin <roel.kluin@gmail.com> wrote on 29/01/2009 15:12:03:
> 
> > With a postfix decrement the timeout will reach -1 rather than 0,
> > so the warning will not be issued.
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> > diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> > index f513bdf..783c1a7 100644
> > --- a/drivers/net/smsc911x.c
> > +++ b/drivers/net/smsc911x.c
> > @@ -953,7 +953,7 @@ smsc911x_rx_fastforward(struct smsc911x_data 
> > *pdata, unsigned int pktbytes)
> >        do {
> >           udelay(1);
> >           val = smsc911x_reg_read(pdata, RX_DP_CTRL);
> > -      } while (timeout-- && (val & RX_DP_CTRL_RX_FFWD_));
> > +      } while (--timeout && (val & RX_DP_CTRL_RX_FFWD_));
> > 
> >        if (unlikely(timeout == 0))
> >           SMSC_WARNING(HW, "Timed out waiting for "
> 
> Thanks for spotting this Roel.
> 
> Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks everyone.
