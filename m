From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] xfrm: netdevice unregistration during decryption
Date: Wed, 9 Mar 2016 10:20:45 +0800
Message-ID: <20160309022045.GA29265@gondor.apana.org.au>
References: <9fb4925ea87677df44c75c435efc329f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35622 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbcCICUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:20:53 -0500
Content-Disposition: inline
In-Reply-To: <9fb4925ea87677df44c75c435efc329f@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2016 at 07:16:23PM -0700, subashab@codeaurora.org wrote:
>
> 2. Encrypted packet queued for decryption (asynchronous)
> 
> static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
> ...
>          aead_request_set_callback(req, 0, esp_input_done, skb);

I suppose we'll have to hold onto the device at this point.  We
may have to hold onto other resources too.

> Would it make sense here to detect the device going away here using a
> netdev notifier callback and free the packets after the asynchronous
> callback returns.

The same path is used for synchronous processing so you can't just
change it to netif_rx_ni unconditionally.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
