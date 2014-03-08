From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sat, 8 Mar 2014 15:53:10 +0100
Message-ID: <20140308145309.GA1615@redhat.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
 <1394241960-1764-1-git-send-email-behanw@converseincode.com>
 <1394243809.6972.4.camel@joe-AO722>
 <531A7D4F.7090303@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, linville@tuxdriver.com,
	johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org,
	pageexec@freemail.hu,
	Jan-Simon =?iso-8859-1?Q?M=F6ller?= <dl9pf@gmx.de>,
	=?iso-8859-1?Q?Vin=EDcius?= Tinti <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: Behan Webster <behanw@converseincode.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <531A7D4F.7090303@converseincode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 07, 2014 at 06:15:43PM -0800, Behan Webster wrote:
> On 03/07/14 17:56, Joe Perches wrote:
> >On Fri, 2014-03-07 at 17:26 -0800, behanw@converseincode.com wrote:
> >>From: Jan-Simon M=F6ller <dl9pf@gmx.de>
> >>
> >>Replaced the use of a Variable Length Array In Struct (VLAIS) with =
a C99
> >>compliant equivalent. This is the original VLAIS struct.
> >[]
> >>diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
> >[]
> >>@@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_ae=
ad *tfm, u8 *b_0, u8 *aad,
> >>  			       u8 *data, size_t data_len, u8 *mic)
> >>  {
> >>  	struct scatterlist assoc, pt, ct[2];
> >>-	struct {
> >>-		struct aead_request	req;
> >>-		u8			priv[crypto_aead_reqsize(tfm)];
> >>-	} aead_req;
> >>-	memset(&aead_req, 0, sizeof(aead_req));
> >>+	char aead_req_data[sizeof(struct aead_request) +
> >>+				crypto_aead_reqsize(tfm) +
> >>+				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
> >Can this be a too large amount of stack?
> >
> >Is crypto_aead_reqsize() limited to < ~1k?
> >
> >Perhaps it'd be better to use kzalloc for this
> >or another reserved pool
> No more stack being used than with the the original code. The stack
> memory use is identical.

Could you explain that? It looks like aead_req_data can be bigger than
original struct aead_req up to CRYPTO_MINALIGN bytes. IOW adding
CRYPTO_MINALIGN to size seems unneeded as aead_request->__ctx alignment
requirement should by assured by proper sizeof(struct aead_request).

Besides, why not add VLAIS feature to llvm instead of fixing all
programs that use it?

Stanislaw
