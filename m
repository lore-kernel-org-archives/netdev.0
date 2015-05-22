From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Fri, 22 May 2015 08:40:25 +0200
Message-ID: <2287044.Rx7bts6Hbt@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <E1YvNxL-00063M-DH@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1YvNxL-00063M-DH@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 21. Mai 2015, 18:44:03 schrieb Herbert Xu:

Hi Herbert,

>-	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
>-	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
>-	aead_givcrypt_set_assoc(req, asg, assoclen);
>-	aead_givcrypt_set_giv(req, esph->enc_data,
>-			      XFRM_SKB_CB(skb)->seq.output.low);
>+	aead_request_set_crypt(req, sg, sg, ivlen + clen, iv);
>+	aead_request_set_ad(req, assoclen, 0);

If I may ask, where in your initial patch set is now decided that the IV 
generator is used (i.e. so that the givcrypt API is not needed any more)?

Do I understand it correctly that you want to retire the givcrypt API 
entirely?

Thanks
Stephan
