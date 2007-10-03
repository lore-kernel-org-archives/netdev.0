From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch 3/3] git-net: sctp build fix (not for applying)
Date: Wed, 03 Oct 2007 09:50:55 -0400
Message-ID: <47039E3F.9020305@hp.com>
References: <200710022104.l92L4dvJ022234@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:42019 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbXJCNu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 09:50:57 -0400
In-Reply-To: <200710022104.l92L4dvJ022234@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> net/sctp/sm_statetable.c:551: error: 'sctp_sf_tabort_8_4_8' undeclared here (not in a function)
> 

Andrew, is the a result of the merge of net-2.6.24 with net-2.6?  

That's the only way I see this happening.

> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  net/sctp/sm_statetable.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff -puN net/sctp/sm_statetable.c~git-net-sctp-hack net/sctp/sm_statetable.c
> --- a/net/sctp/sm_statetable.c~git-net-sctp-hack
> +++ a/net/sctp/sm_statetable.c
> @@ -527,8 +527,6 @@ static const sctp_sm_table_entry_t prsct
>  	/* SCTP_STATE_EMPTY */ \
>  	TYPE_SCTP_FUNC(sctp_sf_ootb), \
>  	/* SCTP_STATE_CLOSED */ \
> -	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
                       ^^^^^^^^^^^^^^^^^^^^
That should be changed to sctp_sf_ootb and then it'll compile.  As is, the patch
is wrong.

Thanks
-vlad

> -	/* SCTP_STATE_COOKIE_WAIT */ \
>  	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
>  	/* SCTP_STATE_COOKIE_ECHOED */ \
>  	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
> _
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

