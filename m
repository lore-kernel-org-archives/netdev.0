From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/7] staging: r8712u: Fix Sparse endian warning in
 rtl871x_recv.c
Date: Mon, 13 Feb 2017 11:29:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0284E3A@AcuExch.aculab.com>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
 <20170211033030.28827-6-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>
To: 'Larry Finger' <Larry.Finger@lwfinger.net>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:61180 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752388AbdBML3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 06:29:54 -0500
In-Reply-To: <20170211033030.28827-6-Larry.Finger@lwfinger.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger
> Sent: 11 February 2017 03:30
> Sparse reports the following:
>   CHECK   drivers/staging/rtl8712/rtl871x_recv.c
> drivers/staging/rtl8712/rtl871x_recv.c:657:21: warning: incorrect type in assignment (different base
> types)
> drivers/staging/rtl8712/rtl871x_recv.c:657:21:    expected unsigned short [unsigned] [assigned]
> [usertype] len
> drivers/staging/rtl8712/rtl871x_recv.c:657:21:    got restricted __be16 [usertype] <noident>
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8712/rtl871x_recv.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
> index 147b75b..2ef31a4 100644
> --- a/drivers/staging/rtl8712/rtl871x_recv.c
> +++ b/drivers/staging/rtl8712/rtl871x_recv.c
> @@ -654,8 +654,9 @@ sint r8712_wlanhdr_to_ethhdr(union recv_frame *precvframe)
>  	memcpy(ptr, pattrib->dst, ETH_ALEN);
>  	memcpy(ptr + ETH_ALEN, pattrib->src, ETH_ALEN);
>  	if (!bsnaphdr) {
> -		len = htons(len);
> -		memcpy(ptr + 12, &len, 2);
> +		__be16 be_tmp = htons(len);
> +
> +		memcpy(ptr + 12, &be_tmp, 2);

Just do:
	ptr[12] = len << 8;
	ptr[13] = len;

	David
