From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/8] textsearch: fix textsearch for case insensitive searching
Date: Sat, 21 Jun 2008 10:21:10 +0200
Message-ID: <485CB9F6.6050601@trash.net>
References: <> <1214034838-1270-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1214034838-1270-1-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote:
> The function textsearch_prepare has new parameter to support case
> insensitive searching.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  include/linux/textsearch.h          |    6 ++++--
>  lib/textsearch.c                    |    6 ++++--
>  net/netfilter/nf_conntrack_amanda.c |    2 +-
>  net/netfilter/xt_string.c           |    2 +-
>  net/sched/em_text.c                 |    2 +-
>  5 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/textsearch.h b/include/linux/textsearch.h
> index 6f371f2..b6897f3 100644
> --- a/include/linux/textsearch.h
> +++ b/include/linux/textsearch.h
> @@ -39,7 +39,7 @@ struct ts_state
>  struct ts_ops
>  {
>  	const char		*name;
> -	struct ts_config *	(*init)(const void *, unsigned int, gfp_t);
> +	struct ts_config *	(*init)(const void *, unsigned int, u8, gfp_t);


This looks fine to me, although a generic flags argument
would prevent changing all users again next time someone
wants to add a feature. But I'll leave that decision to
Thomas.

Thomas, since there are some netfilter patches that depend
on the textsearch patches, do you want me to apply those as
well (haven't reviewed them yet though)?
