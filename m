From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Wed, 27 Feb 2013 10:48:30 +0100
Message-ID: <512DD66E.4040409@suse.cz>
References: <512DCC4A.6060106@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: alan@linux.intel.com, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>, Jiri Kosina <jkosina@suse.cz>,
	isdn@linux-pingi.de, Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:63248 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab3B0Jsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 04:48:35 -0500
Received: by mail-ea0-f179.google.com with SMTP id d12so24733eaa.38
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 01:48:34 -0800 (PST)
In-Reply-To: <512DCC4A.6060106@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 10:05 AM, Chen Gang wrote:
> 
>   the length of cmd.parm.cmsg.para is 50 (MAX_CAPI_PARA_LEN).
>   the strlen(msg) may be more than 50 (Modem-Commandbuffer, less than 255).
>     isdn_tty_send_msg is called by isdn_tty_parse_at
>     the relative parameter is m->mdmcmd (atemu *m)
>     the relative command may be "+M..."
> 
>   so need check the length to be sure not memory overflow.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  drivers/isdn/i4l/isdn_tty.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
> index d8a7d83..c3f0f99 100644
> --- a/drivers/isdn/i4l/isdn_tty.c
> +++ b/drivers/isdn/i4l/isdn_tty.c
> @@ -902,7 +902,7 @@ isdn_tty_send_msg(modem_info *info, atemu *m, char *msg)
>  	int j;
>  	int l;
>  
> -	l = strlen(msg);
> +	l = min(strlen(msg), sizeof(cmd.parm.cmsg.para) - 2);
>  	if (!l) {
>  		isdn_tty_modem_result(RESULT_ERROR, info);
>  		return;
> 

Yeah, looks sensible from the buffer overflow POV. I have no idea if
this is correct from the ISDN POV as we drop the end of the buffer. But
who cares, when nobody noticed in the past decade...

thanks,
-- 
js
suse labs
