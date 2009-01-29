From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: timeout reaches -1
Date: Thu, 29 Jan 2009 15:22:03 +0000
Message-ID: <OF3A0B52EF.AB017C24-ON8025754D.00547404-8025754D.00548C02@smsc.com>
References: <4981C743.90202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2647 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750943AbZA2PX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 10:23:57 -0500
In-Reply-To: <4981C743.90202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin <roel.kluin@gmail.com> wrote on 29/01/2009 15:12:03:

> With a postfix decrement the timeout will reach -1 rather than 0,
> so the warning will not be issued.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index f513bdf..783c1a7 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -953,7 +953,7 @@ smsc911x_rx_fastforward(struct smsc911x_data 
> *pdata, unsigned int pktbytes)
>        do {
>           udelay(1);
>           val = smsc911x_reg_read(pdata, RX_DP_CTRL);
> -      } while (timeout-- && (val & RX_DP_CTRL_RX_FFWD_));
> +      } while (--timeout && (val & RX_DP_CTRL_RX_FFWD_));
> 
>        if (unlikely(timeout == 0))
>           SMSC_WARNING(HW, "Timed out waiting for "

Thanks for spotting this Roel.

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

