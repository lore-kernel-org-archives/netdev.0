From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Fri, 07 Mar 2014 17:56:49 -0800
Message-ID: <1394243809.6972.4.camel@joe-AO722>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
	 <1394241960-1764-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org,
	Jan-Simon =?ISO-8859-1?Q?M=F6ller?= <dl9pf-Mmb7MZpHnFY@public.gmane.org>,
	=?ISO-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394241960-1764-1-git-send-email-behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 17:26 -0800, behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org wrote:
> From: Jan-Simon M=F6ller <dl9pf-Mmb7MZpHnFY@public.gmane.org>
>=20
> Replaced the use of a Variable Length Array In Struct (VLAIS) with a =
C99
> compliant equivalent. This is the original VLAIS struct.
[]
> diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
[]
> @@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead=
 *tfm, u8 *b_0, u8 *aad,
>  			       u8 *data, size_t data_len, u8 *mic)
>  {
>  	struct scatterlist assoc, pt, ct[2];
> -	struct {
> -		struct aead_request	req;
> -		u8			priv[crypto_aead_reqsize(tfm)];
> -	} aead_req;
> =20
> -	memset(&aead_req, 0, sizeof(aead_req));
> +	char aead_req_data[sizeof(struct aead_request) +
> +				crypto_aead_reqsize(tfm) +
> +				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;

Can this be a too large amount of stack?

Is crypto_aead_reqsize() limited to < ~1k?

Perhaps it'd be better to use kzalloc for this
or another reserved pool


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
