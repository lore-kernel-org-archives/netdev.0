From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 23/28] mISDN: Fix compiler warnings
Date: Tue, 24 Apr 2012 09:24:38 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEE@saturn3.aculab.com>
References: <20120423170551.B37049FB98@pingi6.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <isdn4linux@listserv.isdn4linux.de>
To: "Karsten Keil" <isdn@linux-pingi.de>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56384 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753268Ab2DXIYp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:24:45 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12093-02 for <netdev@vger.kernel.org>;
 Tue, 24 Apr 2012 09:24:43 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120423170551.B37049FB98@pingi6.linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c 
> b/drivers/isdn/hardware/mISDN/hfcmulti.c
> index 884c090..144c35a 100644
> --- a/drivers/isdn/hardware/mISDN/hfcmulti.c
> +++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
> @@ -2456,12 +2456,12 @@ handle_timer_irq(struct hfc_multi *hc)
>  		spin_unlock_irqrestore(&HFClock, flags);
>  	}
>  	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
> -		if (hc->created[hc->chan[0].port] && hc->chan[ch].bch &&
> +		ch = 0;
> +		if (hc->created[hc->chan[ch].port] && 
> hc->chan[ch].bch &&
>  		    test_bit(FLG_ACTIVE, &hc->chan[ch].bch->Flags)) {
>  			ch_activ++;
> -			hfcmulti_tx(hc, 0);
> -			hfcmulti_rx(hc, 0);
> -			ch = 1;
> +			hfcmulti_tx(hc, ch);
> +			hfcmulti_rx(hc, ch);
>  			if (hc->chan[ch].dch &&
>  			    hc->chan[ch].nt_timer > -1) {
>  				dch = hc->chan[ch].dch;

That seems to change the fields checked in the final 'if'.
Not sure it is the intended behaviour.

	David
