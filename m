From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive
 pattern matching
Date: Sat, 21 Jun 2008 10:16:08 +0200
Message-ID: <485CB8C8.90106@trash.net>
References: <> <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52479 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbYFUIQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 04:16:12 -0400
In-Reply-To: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> icase of xt_string_info indicates case [in]sensitive matching.
> netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  include/linux/netfilter/xt_string.h |    1 +
>  net/netfilter/xt_string.c           |    2 +-
>  2 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
> index bb21dd1..dfd347f 100644
> --- a/include/linux/netfilter/xt_string.h
> +++ b/include/linux/netfilter/xt_string.h
> @@ -12,6 +12,7 @@ struct xt_string_info
>  	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
>  	u_int8_t  patlen;
>  	u_int8_t  invert;
> +	u_int8_t  icase;
>  
>  	/* Used internally by the kernel */
>  	struct ts_config __attribute__((aligned(8))) *config;


A few words for the changelog why this won't break compatibility
by changing the data structure would be nice, especially
considering CRIS that doesn't perform any padding itself (you
might be lucky though because of aligned attribute, but please
verify that yourself).

