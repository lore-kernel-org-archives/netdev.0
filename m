From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 13:09:40 +0200
Message-ID: <556848F4.6080003@iogearbox.net>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jose.r.guzman.mosqueda@intel.com
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48322 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbbE2LJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 07:09:42 -0400
In-Reply-To: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vadim,

On 05/29/2015 12:30 PM, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Use strdup instead of malloc, and get rid of bad strcpy.
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Please also Cc the reporter (done here), and add a:

Fixes: 8250bc9ff4e5 ("ss: Unify inet sockets output")
Reported-by: Jose R. Guzman Mosqueda <jose.r.guzman.mosqueda@intel.com>

Fixes tag is _very useful_ for distros to easily identify if additional
follow-up commits would be needed when backporting the original change.
Then, this can be easily identified when going through the git log.

> ---
>   misc/ss.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/misc/ss.c b/misc/ss.c
> index 347e3a1..a719466 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1908,8 +1908,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>
>   		if (tb[INET_DIAG_CONG]) {
>   			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
> -			s.cong_alg = malloc(strlen(cong_attr + 1));
> -			strcpy(s.cong_alg, cong_attr);
> +			s.cong_alg = strdup(cong_attr);

strdup(3) can still return NULL.

>   		}
>
>   		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
>
