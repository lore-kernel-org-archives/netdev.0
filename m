From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Fri, 07 Mar 2014 08:24:51 +0100
Message-ID: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
References: <1394135570-26730-1-git-send-email-behanw@converseincode.com>
	 (sfid-20140306_205408_313446_76872588)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	Jan-Simon =?ISO-8859-1?Q?M=F6ller?= <dl9pf@gmx.de>,
	=?ISO-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: behanw@converseincode.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394135570-26730-1-git-send-email-behanw@converseincode.com> (sfid-20140306_205408_313446_76872588)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-06 at 11:52 -0800, behanw@converseincode.com wrote:
> From: Jan-Simon M=C3=B6ller <dl9pf@gmx.de>
>=20
> Replaced the use of a Variable Length Array In Struct (VLAIS) with a =
C99
> compliant equivalent.

=46ine, but

> +	char aead_req_data[sizeof(struct aead_request)
> +				+ crypto_aead_reqsize(tfm)
> +				+ CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;

You really should be using kernel coding style, which changes
indentation and has the + on the previous line.

> +	struct aead_request *aead_req
> +		=3D (struct aead_request *) aead_req_data;

(void *) is perfectly find and it'll probably fit on one line then.

> +	memset(&aead_req_data, 0, (sizeof(struct aead_request)+
> +		crypto_aead_reqsize(tfm) + CRYPTO_MINALIGN));

You don't need the size calculation again, you can use
sizeof(aead_req_data)

johannes
