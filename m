From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: Re: [PATCH] au1000_eth: Duplicate test of RX_OVERLEN bit in
	update_rx_stats()
Date: Tue, 6 Oct 2009 21:53:50 +0200
Message-ID: <f861ec6f0910061253g28743e80r2db772aa7101f098@mail.gmail.com>
References: <4ACBA06A.6050208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	manuel.lauss@gmail.com, "David S. Miller" <davem@davemloft.net>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:55675 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932999AbZJFTy2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:54:28 -0400
Received: by fxm27 with SMTP id 27so4007024fxm.17
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2009 12:53:50 -0700 (PDT)
In-Reply-To: <4ACBA06A.6050208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2009 at 9:54 PM, Roel Kluin <roel.kluin@gmail.com> wrote=
:
> in update_rx_stats() the RX_OVERLEN bit is set twice, replace it by R=
X_RUNT.
> in au1000_rx() the RX_MISSED_FRAME bit was tested a few lines earlier=
 already
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> please review, I merely guessed it should be RX_RUNT.
>
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index fdf5937..04f63c7 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -721,7 +721,7 @@ static inline void update_rx_stats(struct net_dev=
ice *dev, u32 status)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ps->rx_errors++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (status & RX_MISSED_FRAME)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ps->rx_missed_errors++=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status & (RX_OVERLEN | RX_OVERLEN |=
 RX_LEN_ERROR))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status & (RX_OVERLEN | RX_RUNT | RX=
_LEN_ERROR))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ps->rx_length_errors++=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (status & RX_CRC_ERROR)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ps->rx_crc_errors++;
> @@ -794,8 +794,6 @@ static int au1000_rx(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0printk("rx len error\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (st=
atus & RX_U_CNTRL_FRAME)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0printk("rx u control frame\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sta=
tus & RX_MISSED_FRAME)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 printk("rx miss\n");

Yeah, looks right.

Acked-by: Manuel Lauss <manuel.lauss@gmail.com>

       Manuel Lauss
