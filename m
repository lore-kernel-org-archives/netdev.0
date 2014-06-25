From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] dp83640: Program pulsewidth2 values of perout
 triggers 0 and 1
Date: Wed, 25 Jun 2014 21:50:49 +0400
Message-ID: <53AB0BF9.3060101@cogentembedded.com>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com> <1403699851-11178-3-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?U3RlZmFuIFPDuHJlbnNlbg==?=
	<stefan.sorensen@spectralink.com>, davem@davemloft.net,
	richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:61183 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757724AbaFYRur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:50:47 -0400
Received: by mail-lb0-f175.google.com with SMTP id n15so2126391lbi.34
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 10:50:45 -0700 (PDT)
In-Reply-To: <1403699851-11178-3-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/25/2014 04:37 PM, Stefan S=C3=B8rensen wrote:

> Periodic output triggers 0 and 1 of the dp83640 has a programmable
> duty-cycle which is controlled by the Pulsewidth2 field of the trigge=
r
> data register.  This field is not documented in the datasheet, but it
> is described in the "PHYTER Software Development Guide" section
> 3.1.4.1. Failing to set the field can result in unstable/no trigger
> output.

> Add programming of the Pulsewidth2 field, setting it to the same valu=
e
> as the Pulsewidth field for a 50% duty cycle.

> Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
> ---
>   drivers/net/phy/dp83640.c | 5 +++++
>   1 file changed, 5 insertions(+)

> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> index 73fada9..0343b6c 100644
> --- a/drivers/net/phy/dp83640.c
> +++ b/drivers/net/phy/dp83640.c
> @@ -353,6 +353,11 @@ static int periodic_output(struct dp83640_clock =
*clock,
>   	ext_write(0, phydev, PAGE4, PTP_TDR, sec >> 16);       /* sec[31:1=
6] */
>   	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth & 0xffff); /* ns[15:0]=
 */
>   	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth >> 16);    /* ns[31:16=
] */
> +	/* Triggers 0 and 1 has programmable pulsewidth2 */
> +	if(trigger < 2) {

    Please run your patches thru scripts/checkpatch.pl -- space is need=
ed=20
after *if*.

WBR, Sergei
