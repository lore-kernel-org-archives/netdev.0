From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next 3/6] {IPv4,xfrm} Add ESN support for AH
 ingress part
Date: Thu, 16 Jan 2014 10:56:47 +0100
Message-ID: <20140116095647.GL31491@secunet.com>
References: <1389769995-350-1-git-send-email-fan.du@windriver.com>
 <1389769995-350-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52458 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369AbaAPJ4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 04:56:50 -0500
Content-Disposition: inline
In-Reply-To: <1389769995-350-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 03:13:12PM +0800, Fan Du wrote:
>  
> -	ahash_request_set_crypt(req, sg, icv, skb->len);
> +	if (x->props.flags & XFRM_STATE_ESN) {
> +		/* Attach seqhi sg right after packet payload */
> +		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.input.hi);

XFRM_SKB_CB(skb)->seq.input.hi is already in network byte order,
please remove the htonl(). The ipv6 patch has the same problem.
