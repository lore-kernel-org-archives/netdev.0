From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Wed, 19 Mar 2014 14:51:53 +0100
Message-ID: <1395237113.4142.5.camel@jlt4.sipsolutions.net>
References: <CABikg9x+Z95bHcDc6iu5hBvRNO-ibM8-34_qA+OA_FjB52SPMw@mail.gmail.com>
	 <1395199933-4686-1-git-send-email-behanw@converseincode.com>
	 (sfid-20140319_043225_892297_337F53BC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	Jan-Simon =?ISO-8859-1?Q?M=F6ller?= <dl9pf@gmx.de>,
	=?ISO-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: behanw@converseincode.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395199933-4686-1-git-send-email-behanw@converseincode.com> (sfid-20140319_043225_892297_337F53BC)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm confused.

On Tue, 2014-03-18 at 20:32 -0700, behanw@converseincode.com wrote:


>  	struct scatterlist assoc, pt, ct[2];
> -	struct {
> -		struct aead_request	req;
> -		u8			priv[crypto_aead_reqsize(tfm)];
> -	} aead_req;
>  
> -	memset(&aead_req, 0, sizeof(aead_req));
> +	char aead_req_data[sizeof(struct aead_request) +
> +		crypto_aead_reqsize(tfm)]
> +		__aligned(__alignof__(struct aead_request));

This looks fine, though I'd argue the blank lines before/after it
shouldn't be there, and the indentation should be a bit different, but I
was willing to clean that up.

>  int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
>  			      u8 *data, size_t data_len, u8 *mic)
>  {
>  	struct scatterlist assoc, pt, ct[2];
> -	struct {
> -		struct aead_request	req;
> -		u8			priv[crypto_aead_reqsize(tfm)];
> -	} aead_req;
>  
> -	memset(&aead_req, 0, sizeof(aead_req));
> +	char aead_req_data[sizeof(struct aead_request) +
> +				crypto_aead_reqsize(tfm) +
> +				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;

But why does the second instance use a completely different size/align?

johannes
