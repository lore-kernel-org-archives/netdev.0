From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/5] sctp: remove the else path
Date: Thu, 07 Nov 2013 19:00:44 -0800
Message-ID: <1383879644.9263.62.camel@joe-AO722>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
	 <1383879310-22792-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	dingtianhong@huawei.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0146.hostedemail.com ([216.40.44.146]:42120 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755126Ab3KHDAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 22:00:38 -0500
In-Reply-To: <1383879310-22792-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 10:55 +0800, Wang Weidong wrote:
> Make the code more simplification.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/associola.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 667f984..2d53d4c 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -954,15 +954,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
>   */
>  struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
>  {
> -	struct sctp_chunk *chunk;
> +	struct sctp_chunk *chunk = NULL;
>  
>  	/* Send ECNE if needed.
>  	 * Not being able to allocate a chunk here is not deadly.
>  	 */
>  	if (asoc->need_ecne)
>  		chunk = sctp_make_ecne(asoc, asoc->last_ecne_tsn);
> -	else
> -		chunk = NULL;
>  
>  	return chunk;
>  }

If you really want to make the code simple how about:

struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
{
	if (!asoc->need_ecne)
		return NULL;

	return sctp_make_ecne(asoc, asoc->last_ecne_tsn);
}
