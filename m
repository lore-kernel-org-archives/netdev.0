From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 10/10] ss: extended json_writer for hex field and
 value output
Date: Mon, 31 Aug 2015 12:20:04 -0700
Message-ID: <20150831122004.3a3aba15@urahara>
References: <1440941075-26478-1-git-send-email-matthias.tafelmeier@gmx.net>
	<ec6b5a61cd6849f5bc3f1707fab052b6@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33505 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbbHaTTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:19:53 -0400
Received: by paczk9 with SMTP id zk9so206817pac.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 12:19:53 -0700 (PDT)
In-Reply-To: <ec6b5a61cd6849f5bc3f1707fab052b6@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> diff --git a/lib/json_writer.c b/lib/json_writer.c
> index 2af16e1..495ce57 100644
> --- a/lib/json_writer.c
> +++ b/lib/json_writer.c
> @@ -22,6 +22,8 @@
>  
>  #include "json_writer.h"
>  
> +#define notused
> +

Gack. Just take out the #ifdef

>  struct json_writer {
>  	FILE		*out;	/* output file */
>  	unsigned	depth;  /* nesting */
> @@ -223,6 +225,14 @@ void jsonw_int(json_writer_t *self, int64_t num)
>  	jsonw_printf(self, "%"PRId64, num);
>  }
>  
> +void jsonw_hex(json_writer_t *self, uint64_t num)
> +{
> +	char tmp[17];
> +
> +	sprintf(tmp, "%"PRIx64, num);
> +	jsonw_string(self, tmp);
> +}
> +

No. JSON is a standard. The output has to be one of the formats in the
standard. hex is a display issue not an encoding style.
