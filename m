From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 16:33:35 +0100
Message-ID: <1482420815.2673.1.camel@stressinduktion.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
	 <20161221230216.25341-1-Jason@zx2c4.com>
	 <20161221230216.25341-4-Jason@zx2c4.com>
	 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
	 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
	 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
	 <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
	 <1482410840.2472.2.camel@stressinduktion.org>
	 <CAHmME9r_zTHo=dxRRK6UrjJ_dKV14yYsZsxCc362z4CPoVkddw@mail.gmail.com>
	 <5c306c80-3499-8b92-21d0-c197f30ce326@stressinduktion.org>
	 <CAHmME9qZviooxOW+e=khazG0phSEWwZyKj=eayre_7hs8d+cQw@mail.gmail.com>
	 <CAHmME9pu-2CY2WRHevnpwo-9qnZcTpqQgC2voGFOpSjo+LPiUA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-hardening@lists.openwall.com, Theodore Ts'o <tytso@mit.edu>, Andy
 Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>, LKML
 <linux-kernel@vger.kernel.org>,  Linux Crypto Mailing List
 <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
 Eric Dumazet <edumazet@google.com>,  Linus Torvalds
 <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>, Tom
 Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>, "David S.
 Miller" <davem@davemloft.net>, Jean-Philippe Aumasson
 <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5781-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9pu-2CY2WRHevnpwo-9qnZcTpqQgC2voGFOpSjo+LPiUA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-22 at 16:29 +0100, Jason A. Donenfeld wrote:
> On Thu, Dec 22, 2016 at 4:12 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> > As a first step, I'm considering adding a patch to move halfmd4.c
> > inside the ext4 domain, or at the very least, simply remove it from
> > linux/cryptohash.h. That'll then leave the handful of bizarre sha1
> > usages to consider.
> 
> Specifically something like this:
> 
> https://git.zx2c4.com/linux-dev/commit/?h=siphash&id=978213351f9633bd1e3d1fdc3f19d28e36eeac90
> 
> That only leaves two more uses of "cryptohash" to consider, but they
> require a bit of help. First, sha_transform in net/ipv6/addrconf.c.
> That might be a straight-forward conversion to SipHash, but perhaps
> not; I need to look closely and think about it. The next is
> sha_transform in kernel/bpf/core.c. I really have no idea what's going
> on with the eBPF stuff, so that will take a bit longer to study. Maybe
> sha1 is fine in the end there? I'm not sure yet.

IPv6 you cannot touch anymore. The hashing algorithm is part of uAPI.
You don't want to give people new IPv6 addresses with the same stable
secret (across reboots) after a kernel upgrade. Maybe they lose
connectivity then and it is extra work?

The bpf hash stuff can be changed during this merge window, as it is
not yet in a released kernel. Albeit I would probably have preferred
something like sha256 here, which can be easily replicated by user
space tools (minus the problem of patching out references to not
hashable data, which must be zeroed).

Bye,
Hannes
