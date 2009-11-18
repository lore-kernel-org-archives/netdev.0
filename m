From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Wed, 18 Nov 2009 16:08:55 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911181600400.7024@wel-95.cs.helsinki.fi>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com> <4B01BB33.7080702@gmail.com> <4B01BF65.1010203@gmail.com> <4B01CD8D.1000305@gmail.com> <4B01D17C.4010407@gmail.com>
 <alpine.DEB.2.00.0911171402260.7024@wel-95.cs.helsinki.fi> <4B03FCE4.5020403@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-713708243-1258553053=:7024"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39768 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbZKROIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 09:08:51 -0500
In-Reply-To: <4B03FCE4.5020403@gmail.com>
Content-ID: <alpine.DEB.2.00.0911181605510.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-713708243-1258553053=:7024
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911181605511.7024@wel-95.cs.helsinki.fi>

On Wed, 18 Nov 2009, William Allen Simpson wrote:

> Ilpo Järvinen wrote:
> > You both are right (and that's what is causing confusion)...
> > 
> In this case, for /this/ code, *none* of you are correct, and _that's_
> causing confusion. There is no independent retransmission of SYNACK data!
> None!!  Nada!!!  There is no retransmission queue for SYNACK data.
> 
> SYN with SACK should never be sent, and should never be received -- and
> already should be discarded and ignored (outside the scope of this patch).
> 
> As I've already mentioned in this thread 2 days ago, in my earlier patches
> (now deferred to part 2 after the functional split requested by Eric and
> Ilpo), the request_sock was removed entirely (just like syncookies).
> There wasn't (and won't be) any struct or timer lying around to allow
> SYNACK data retransmissions to occur.
> 
> Even now, the entire s_data_* edifice isn't passed to be retransmitted.
> Note the code (in part 1a), already reviewed and Ack'd:
> 
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 4be2228..7a42990 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -537,7 +537,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff
> *skb,
>  		 * Enforce "SYN-ACK" according to figure 8, figure 6
>  		 * of RFC793, fixed by RFC1122.
>  		 */
> -		req->rsk_ops->rtx_syn_ack(sk, req);
> +		req->rsk_ops->rtx_syn_ack(sk, req, NULL);
>  		return NULL;
>  	}
> 
> See that NULL?  There's no cookie data structure for retransmission!
> 
> Could we end this diversion into rampant speculation?

...I was just commenting on the disagreement in the interpretation of what 
DaveM said vs comments you mentioned... :-)

-- 
 i.
--8323329-713708243-1258553053=:7024--
