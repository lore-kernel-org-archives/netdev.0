From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 14:09:36 -0700
Message-ID: <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
References: <20150902.223522.1792493140210966693.davem@davemloft.net> <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com> <20150903.104032.767889134756094076.davem@davemloft.net> <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com> <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

>> [-Wsizeof-array-argument]
> 
> Ahh. Google shows that it's an old clang warning that gcc has recently
> picked up.
> 
> But even clang doesn't seem to have any way for a project to say
> "please warn about arrays in function argument declaration". It *is*
> very traditional idiomatic C, it's just that I personally think it's
> one of those bad traditional C things exactly because it's so
> misleading about what actually goes on. But I guess that in practice,
> the only thing that it actually *affects* is "sizeof" (and assignment
> to the variable name - something that would be invalid for a real
> array, but works on argument arrays because they are really just
> pointers).
> 
> The "array as function argument" syntax is occasionally useful
> (particularly for the multi-dimensional array case), so I very much
> understand why it exists, I just think that in the kernel we'd be
> better off with the rule that it's against our coding practices.

I find them useful as syntactic sugar. We have not used them a lot, but there are cases in our crypto handling code where we have fixed size array inputs/outputs and there we opted to use them. They make it easy to remember what the expected sizes of input and output are without having to read through the implementation (of course we never even tried to use sizeof on these pointers).

static int smp_ah(struct crypto_blkcipher *tfm, const u8 irk[16],                
                  const u8 r[3], u8 res[3])

This is one of the simple crypto hashing for privacy keys we have.

	r' = padding || r
	ah(h, r) = e(k, r') mod 2^24

We are fully aware that const u8 r[3] is const u8 *r. As I said, it is syntactic sugar for us and nothing more.

Regards

Marcel
