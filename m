From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 1/2] net: sctp: spare unnecessary comparison in sctp_trans_elect_best
Date: Fri, 22 Aug 2014 10:38:01 -0400
Message-ID: <53F755C9.3020103@gmail.com>
References: <1408705410-28558-1-git-send-email-dborkman@redhat.com> <1408705410-28558-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:63713 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbaHVOiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 10:38:05 -0400
In-Reply-To: <1408705410-28558-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2014 07:03 AM, Daniel Borkmann wrote:
> When both transports are the same, we don't have to go down that
> road only to realize that we will return the very same transport.
> We are guaranteed that curr is always non-NULL. Therefore, just
> short-circuit this special case.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/associola.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index aaafb32..104fae4 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1245,7 +1245,7 @@ static struct sctp_transport *sctp_trans_elect_best(struct sctp_transport *curr,
>  {
>  	u8 score_curr, score_best;
>  
> -	if (best == NULL)
> +	if (best == NULL || curr == best)
>  		return curr;
>  
>  	score_curr = sctp_trans_score(curr);
> 
