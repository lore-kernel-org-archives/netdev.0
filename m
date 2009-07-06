From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2] sctp: fix warning at inet_sock_destruct() while
	release sctp socket
Date: Mon, 6 Jul 2009 14:49:57 +0800
Message-ID: <20090706064957.GA16971@gondor.apana.org.au>
References: <4A518EDF.9030501@cn.fujitsu.com> <4A518F8C.2090807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53004 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750910AbZGFGuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 02:50:04 -0400
Content-Disposition: inline
In-Reply-To: <4A518F8C.2090807@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 01:45:48PM +0800, Wei Yongjun wrote:
> Commit 'net: Move rx skb_orphan call to where needed' broken sctp protocol
> with warning at inet_sock_destruct(). Actually, sctp can do this right with
> sctp_sock_rfree_frag() and sctp_skb_set_owner_r_frag() pair.
> 
>     sctp_sock_rfree_frag(skb);
>     sctp_skb_set_owner_r_frag(skb, newsk);
> 
> This patch not revert the commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f,
> instead remove the sctp_sock_rfree_frag() function.

It took me a while to understand your patch but yeah it does seem
to be the right fix.  So essentially we were freeing the packet
twice as my newly added skb_orphan in sctp_skb_set_owner_r is
repeating what sctp_sock_rfree_frag has already done for the
migration case.

While your patch simply eliminates sctp_sock_rfree_frag so that
we only free things once.
 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
