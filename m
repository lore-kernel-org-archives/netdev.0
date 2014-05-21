From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] mISDN: Use time_before()
Date: Wed, 21 May 2014 23:27:37 +0400
Message-ID: <537CFE29.7050100@cogentembedded.com>
References: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?B?TWFudWVsIFNjaMO2bGxpbmc=?= <manuel.schoelling@gmx.de>,
	isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:65060 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbaEUT1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 15:27:34 -0400
Received: by mail-la0-f51.google.com with SMTP id gf5so1895787lab.24
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 12:27:33 -0700 (PDT)
In-Reply-To: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/21/2014 11:10 PM, Manuel Sch=C3=B6lling wrote:

> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_before() instead of plain, error-prone math.

> Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
> ---
>   drivers/isdn/mISDN/l1oip_core.c |    5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)

> diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1o=
ip_core.c
> index 2c0d2c2..1c2bc36 100644
> --- a/drivers/isdn/mISDN/l1oip_core.c
> +++ b/drivers/isdn/mISDN/l1oip_core.c
> @@ -287,7 +287,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec=
, u8 channel, u32 chanmask,
>   	p =3D frame;
>
>   	/* restart timer */
> -	if ((int)(hc->keep_tl.expires-jiffies) < 5 * HZ) {
> +	if (time_before(hc->keep_tl.expires - 5 * HZ, jiffies)) {

    Wouldn't it be clearer this way:

	if (time_before(hc->keep_tl.expires, jiffies + 5 * HZ)) {

>   		del_timer(&hc->keep_tl);
>   		hc->keep_tl.expires =3D jiffies + L1OIP_KEEPALIVE * HZ;
>   		add_timer(&hc->keep_tl);
> @@ -621,7 +621,8 @@ multiframe:
>   		goto multiframe;
>
>   	/* restart timer */
> -	if ((int)(hc->timeout_tl.expires-jiffies) < 5 * HZ || !hc->timeout_=
on) {
> +	if (time_before(hc->timeout_tl.expires - 5 * HZ, jiffies)
> +	    || !hc->timeout_on) {

    Please leave || on the previous line.

WBR, Sergei
