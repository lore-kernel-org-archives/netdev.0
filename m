From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: fix BUG on non-linear SKB (multilink receive)
Date: Mon, 16 Nov 2009 23:52:54 -0800 (PST)
Message-ID: <20091116.235254.148428748.davem@davemloft.net>
References: <Pine.LNX.4.58.0911121144380.25398@benxen>
	<20091113.194650.214404898.davem@davemloft.net>
	<Pine.LNX.4.58.0911161334240.15274@benxen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: ben@netservers.co.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0911161334240.15274@benxen>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben McKeegan <ben@netservers.co.uk>
Date: Mon, 16 Nov 2009 13:44:25 +0000 (GMT)

> PPP does not correctly call pskb_may_pull() on all necessary receive paths
> before reading the PPP protocol, thus causing PPP to report seemingly
> random 'unsupported protocols' and eventually trigger BUG_ON(skb->len <
> skb->data_len) in skb_pull_rcsum() when receiving multilink protocol in
> non-linear skbs.
> 
> ppp_receive_nonmp_frame() does not call pskb_may_pull() before reading the
> protocol number.  For the non-mp receive path this is not a problem, as
> this check is done in ppp_receive_frame().  For the mp receive path,
> ppp_mp_reconstruct() usually copies the data into a new linear skb.
> However, in the case where the frame is made up of a single mp fragment,
> the mp header is pulled and the existing skb used.  This skb was then
> passed to ppp_receive_nonmp_frame() without checking if the encapsulated
> protocol header could safely be read.
> 
> Signed-off-by: Ben McKeegan <ben@netservers.co.uk>

Applied but:

> +	while ((skb = ppp_mp_reconstruct(ppp))) {
> +	  	if (pskb_may_pull(skb, 2))

There is a mix of space and tab characters leading up to
the "if (pskb_may_pull" there, I fixed it up but please
take care of such trivial issues before submitting your
patch next time.

Thanks.
