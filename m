From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 4/6] net: fec: Increase buffer descriptor entry number
Date: Wed, 4 Jun 2014 09:26:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17256FBF@AcuExch.aculab.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
 <1401867571-11684-5-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"R49496@freescale.com" <R49496@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"b20596@freescale.com" <b20596@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: 'Fugang Duan' <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53177 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751320AbaFDJ1R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:27:17 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00316-01 for <netdev@vger.kernel.org>;
 Wed,  4 Jun 2014 10:27:07 +0100 (BST)
In-Reply-To: <1401867571-11684-5-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan
> In order to support SG, software TSO, let's increase BD entry number.
> 
> CC: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |    6 +++---
>  drivers/net/ethernet/freescale/fec_main.c |   21 ++++++++++++---------
>  2 files changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index 3b8d6d1..798ad88 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -240,14 +240,14 @@ struct bufdesc_ex {
>   * the skbuffer directly.
>   */
> 
> -#define FEC_ENET_RX_PAGES	8
> +#define FEC_ENET_RX_PAGES	128
>  #define FEC_ENET_RX_FRSIZE	2048
>  #define FEC_ENET_RX_FRPPG	(PAGE_SIZE / FEC_ENET_RX_FRSIZE)
>  #define RX_RING_SIZE		(FEC_ENET_RX_FRPPG * FEC_ENET_RX_PAGES)
> ...

You are changing the number of rx descriptors as well.
This isn't mentioned in the description.

And, as I said before, basing this on PAGE_SIZE cannot be right.

	David
