From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ethernet: marvell: sky2.c:  Cleaning up missing
 null-terminate in conjunction with strncpy
Date: Sun, 14 Sep 2014 20:19:10 -0700
Message-ID: <20140914201910.1de7b857@urahara>
References: <1410716023-16068-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42423 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbaIODTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 23:19:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so5394161pab.33
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 20:19:13 -0700 (PDT)
In-Reply-To: <1410716023-16068-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Sep 2014 19:33:43 +0200
Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:

> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/ethernet/marvell/sky2.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index dba48a5c..7053d38 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -4907,7 +4907,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
>  	};
>  
>  	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OP_2)
> -		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
> +		strlcpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
>  	else
>  		snprintf(buf, sz, "(chip %#x)", chipid);
>  	return buf;

Useless and unnecessary since the list of names is right there.
Why not avoid the copy?
