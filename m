From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] drivers/isdn: break out of the loop after call isdn_tty_send_msg
Date: Thu, 28 Feb 2013 10:54:54 +0100
Message-ID: <512F296E.1050303@suse.cz>
References: <512DD2B3.2070404@asianux.com> <512DD94C.2020008@suse.cz> <512EC79C.3010700@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:45371 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3B1Jy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 04:54:57 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so1254173eek.39
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 01:54:56 -0800 (PST)
In-Reply-To: <512EC79C.3010700@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 03:57 AM, Chen Gang wrote:
> 
>   need break out of the loop after call isdn_tty_send_msg.
>     isdn_tty_send_msg is intended to eat the rest of the string.
>     so need not scan again the string which appended "+M...".

Yes, looks good.

> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  drivers/isdn/i4l/isdn_tty.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
> index d8a7d83..8ac7b33 100644
> --- a/drivers/isdn/i4l/isdn_tty.c
> +++ b/drivers/isdn/i4l/isdn_tty.c
> @@ -3587,7 +3587,7 @@ isdn_tty_parse_at(modem_info *info)
>  			case 'M':	/* MESSAGE */
>  				p++;
>  				isdn_tty_send_msg(info, m, p);
> -				break;
> +				goto tail;
>  			default:
>  				PARSE_ERROR;
>  			}
> @@ -3601,6 +3601,8 @@ isdn_tty_parse_at(modem_info *info)
>  			PARSE_ERROR;
>  		}
>  	}
> +
> +tail:
>  #ifdef CONFIG_ISDN_AUDIO
>  	if (!info->vonline)
>  #endif
> 


-- 
js
suse labs
