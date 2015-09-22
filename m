From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] lib: fix data race in rhashtable_rehash_one
Date: Tue, 22 Sep 2015 23:19:57 +0800
Message-ID: <20150922151957.GA13278@gondor.apana.org.au>
References: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch, kcc@google.com,
	andreyknvl@google.com, glider@google.com, ktsan@googlegroups.com,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442911912-66882-1-git-send-email-dvyukov@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Vyukov <dvyukov@google.com> wrote:
> rhashtable_rehash_one() uses complex logic to update entry->next field,
> after INIT_RHT_NULLS_HEAD and NULLS_MARKER expansion:
> 
> entry->next = 1 | ((base + off) << 1)
> 
> This can be compiled along the lines of:
> 
> entry->next = base + off
> entry->next <<= 1
> entry->next |= 1
> 
> Which will break concurrent readers.
> 
> NULLS value recomputation is not needed here, so just remove
> the complex logic.
> 
> The data race was found with KernelThreadSanitizer (KTSAN).
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
