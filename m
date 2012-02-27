From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix comment for tp->highest_sack
Date: Tue, 28 Feb 2012 00:56:41 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1202280053320.17924@melkinpaasi.cs.helsinki.fi>
References: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-907145507-1330383320=:17924"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39483 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322Ab2B0W4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 17:56:43 -0500
In-Reply-To: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Content-ID: <alpine.DEB.2.00.1202280055270.17924@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-907145507-1330383320=:17924
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1202280055271.17924@melkinpaasi.cs.helsinki.fi>

On Mon, 27 Feb 2012, Neal Cardwell wrote:

> There was an off-by-one error in the comments describing the
> highest_sack field in struct tcp_sock. The comments previously claimed
> that it was the "start sequence of the highest skb with SACKed
> bit". This commit fixes the comments to note that it is the "start
> sequence of the skb just *after* the highest skb with SACKed bit".
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  include/linux/tcp.h |    3 ++-
>  include/net/tcp.h   |    5 +++--
>  2 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 46a85c9..3c7ffdb 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -412,7 +412,8 @@ struct tcp_sock {
>  
>  	struct tcp_sack_block recv_sack_cache[4];
>  
> -	struct sk_buff *highest_sack;   /* highest skb with SACK received
> +	struct sk_buff *highest_sack;   /* skb just after the highest
> +					 * skb with SACKed bit set
>  					 * (validity guaranteed only if
>  					 * sacked_out > 0)
>  					 */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 42c29bf..2d80c29 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1364,8 +1364,9 @@ static inline void tcp_push_pending_frames(struct sock *sk)
>  	}
>  }
>  
> -/* Start sequence of the highest skb with SACKed bit, valid only if
> - * sacked > 0 or when the caller has ensured validity by itself.
> +/* Start sequence of the skb just after the highest skb with SACKed
> + * bit, valid only if sacked_out > 0 or when the caller has ensured
> + * validity by itself.
>   */
>  static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
>  {

Right, commenting code in the first place is evil as we see. ...I remember 
changing this at some point, perhaps already before the submission but 
never managed to detect the errors in those non-compile tested
comments. :-)

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--8323329-907145507-1330383320=:17924--
