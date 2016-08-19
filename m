From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 15:49:17 +0000
Message-ID: <AM5PR0401MB2561CB4CA30BC13EBFFAD43796160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0073.outbound.protection.outlook.com ([104.47.2.73]:47018
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932268AbcHSQWc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 12:22:32 -0400
In-Reply-To: <20160819145900.GD7343@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andrew Lunn [mailto:andrew@lunn.ch]
>Sent: Friday, August 19, 2016 5:59 PM
>To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>Cc: netdev@vger.kernel.org; claudiu.manoil@freescale.com
>Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
>
>On Fri, Aug 19, 2016 at 11:16:14AM +0200, Zefir Kurtisi wrote:
>> The eTSEC register MRBLR defines the maximum space in
>> the RX buffers and is set to 1536 by gianfar. This
>> reasonably covers the common use case where the MTU
>> is kept at default 1500.
>>
>> Alas, if the eTSEC is attached to a DSA enabled switch,
>> the DSA header extension causes every maximum sized
>> frame to be fragmented by the hardware (1536 + 4).
>>
>> This patch increases the maximum RX buffer size by
>> RBUF_ALIGNMENT (64) octets. Since the driver uses a
>> half-page memory schema, this change does not
>> increase allocated memory but allows the hardware to
>> use 1600 bytes of the totally available 2048.
>>
>> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>> ---
>>  drivers/net/ethernet/freescale/gianfar.h | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.h
>b/drivers/net/ethernet/freescale/gianfar.h
>> index 373fd09..02b794b 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.h
>> +++ b/drivers/net/ethernet/freescale/gianfar.h
>> @@ -100,7 +100,8 @@ extern const char gfar_driver_version[];
>>  #define DEFAULT_RX_LFC_THR  16
>>  #define DEFAULT_LFC_PTVVAL  4
>>
>> -#define GFAR_RXB_SIZE 1536
>> +/* prevent fragmenation by HW in DSA environments */
>> +#define GFAR_RXB_SIZE (1536 + RXBUF_ALIGNMENT)
>
>Hi Zefir
>
>Using RXBUF_ALIGNMENT suggests this has something to do with
>alignment, not extra headers.
>
>How about
>
>/* Prevent fragmenation by HW when using extra headers like DSA */
>#define GFAR_RXB_SIZE (1536 + 8)
>

MRBL (Maximum receive buffer length) must be multiple of 64.
Please consult de hardware documentation at least before prosing
changes to the driver.

Claudiu
