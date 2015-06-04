From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [v2 PATCH 5/13] crypto: testmgr - Switch to new AEAD interface
Date: Thu, 04 Jun 2015 15:15:19 -0700
Message-ID: <5570CDF7.4090308@intel.com>
References: <20150522082708.GA3507@gondor.apana.org.au> <E1YviM1-0000xu-GV@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1YviM1-0000xu-GV@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,
On 05/22/2015 01:30 AM, Herbert Xu wrote:
> This patch makes use of the new AEAD interface which uses a single
> SG list instead of separate lists for the AD and plain text.

The fact the src and assoc point to the same sgl causes some inconsistency. The input I'm getting is:
req->old = 1
req->src_nents = 1
req->src_len = 80
req->dst_nents = 1
req->dst_len = 80
req->assoclen = 0

but

req->assoc_nents = 1
req->assoc_len = 80

I presume req->assoc is obsolete now and drivers need to use req->assoclen. right?
Currently I just loop over req->assoc to get the AD.
regards,
T
