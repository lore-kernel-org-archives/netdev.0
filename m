From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/17] qla3xxx: convert byte order of constant instead
 of variable
Date: Wed, 26 Mar 2008 00:36:33 -0400
Message-ID: <47E9D2D1.3030600@garzik.org>
References: <200803042319.m24NJKLT002661@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcin.slusarz@gmail.com,
	ron.mercer@qlogic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34252 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbYCZEgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:36:35 -0400
In-Reply-To: <200803042319.m24NJKLT002661@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Marcin Slusarz <marcin.slusarz@gmail.com>
> 
> Convert byte order of constant instead of variable which can be done at
> compile time (vs run time)
> 
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> Acked-by: Ron Mercer <ron.mercer@qlogic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/qla3xxx.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff -puN drivers/net/qla3xxx.c~qla3xxx-convert-byte-order-of-constant-instead-of-variable drivers/net/qla3xxx.c
> --- a/drivers/net/qla3xxx.c~qla3xxx-convert-byte-order-of-constant-instead-of-variable
> +++ a/drivers/net/qla3xxx.c
> @@ -2472,8 +2472,7 @@ static int ql_send_map(struct ql3_adapte
>  
>  	if (seg_cnt == 1) {
>  		/* Terminate the last segment. */
> -		oal_entry->len =
> -		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
> +		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
>  	} else {
>  		oal = tx_cb->oal;
>  		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
> @@ -2530,8 +2529,7 @@ static int ql_send_map(struct ql3_adapte
>  					  frag->size);
>  		}
>  		/* Terminate the last segment. */
> -		oal_entry->len =
> -		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
> +		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
>  	}
>  

applied


