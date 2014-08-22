From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 2/2] net: sctp: fix suboptimal edge-case on non-active
 active/retrans path selection
Date: Fri, 22 Aug 2014 10:39:36 -0400
Message-ID: <53F75628.8050109@gmail.com>
References: <1408705410-28558-1-git-send-email-dborkman@redhat.com> <1408705410-28558-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:45199 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290AbaHVOjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 10:39:39 -0400
In-Reply-To: <1408705410-28558-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2014 07:03 AM, Daniel Borkmann wrote:
> In SCTP, selection of active (T.ACT) and retransmission (T.RET)
> transports is being done whenever transport control operations
> (UP, DOWN, PF, ...) are engaged through sctp_assoc_control_transport().
> 
> Commits 4c47af4d5eb2 ("net: sctp: rework multihoming retransmission
> path selection to rfc4960") and a7288c4dd509 ("net: sctp: improve
> sctp_select_active_and_retran_path selection") have both improved
> it towards a more fine-grained and optimal path selection.
> 
.. snip excellent changelog description ...

>     T2 S(ACTIVE) T.RET
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>  net/sctp/associola.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 104fae4..a88b852 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1356,14 +1356,11 @@ static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
>  		trans_sec = trans_pri;
>  
>  	/* If we failed to find a usable transport, just camp on the
> -	 * primary or retran, even if they are inactive, if possible
> -	 * pick a PF iff it's the better choice.
> +	 * active or pick a PF iff it's the better choice.
>  	 */
>  	if (trans_pri == NULL) {
> -		trans_pri = sctp_trans_elect_best(asoc->peer.primary_path,
> -						  asoc->peer.retran_path);
> -		trans_pri = sctp_trans_elect_best(trans_pri, trans_pf);
> -		trans_sec = asoc->peer.primary_path;
> +		trans_pri = sctp_trans_elect_best(asoc->peer.active_path, trans_pf);
> +		trans_sec = trans_pri;
>  	}
>  
>  	/* Set the active and retran transports. */
> 
