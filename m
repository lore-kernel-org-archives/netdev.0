From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 00/11] rename random32 to prandom and introduce
 prandom_bytes()
Date: Tue, 13 Nov 2012 11:55:57 -0800
Message-ID: <20121113115557.9b573359.akpm@linux-foundation.org>
References: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-mtd@lists.infradead.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	Robert Love <robert.w.love@intel.com>, devel@open-fcoe.org,
	Michel Lespinasse <walken@google.com>
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2012 22:36:59 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> This patchset introduces new functions into random32 library for
> getting the requested number of pseudo-random bytes.
> 
> Before introducing these new functions into random32 library,
> rename all random32 functions to have 'prandom_' prefix.  As a result
> the function prototypes are as follows:
> 
> void prandom_seed(u32 seed);	/* rename from srandom32() */
> u32 prandom_u32(void);		/* rename from random32() */
> void prandom_bytes(void *buf, int nbytes);
> 
> void prandom_seed_state(struct rnd_state *state, u64 seed);
> 				/* rename from prandom32_seed() */
> u32 prandom_u32_state(struct rnd_state *state);
> 				/* rename from prandom32() */
> void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
> 
> The purpose of this renaming is to prevent some kernel developers
> from assuming that prandom32() and random32() might imply that only
> prandom32() was the one using a pseudo-random number generator by
> prandom32's "p", and the result may be a very embarassing security
> exposure.  This concern was expressed by Theodore Ts'o.

There were a large number of rejects in MTD code, due to pending
changes in linux-next.  It's all quite mechanical stuff which I
fixed up.  Please check the result.
