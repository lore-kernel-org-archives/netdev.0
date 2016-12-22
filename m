From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 19:19:12 +0100
Message-ID: <CAHmME9rPzhi456Jq5z7cFZnjfJeWUiHyxxdXL882s2TZPwvF=g@mail.gmail.com>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
 <1482425969.2673.5.camel@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Theodore Ts'o" <tytso@mit.edu>,
	Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5801-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1482425969.2673.5.camel@stressinduktion.org>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 5:59 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> We don't prevent ebpf programs being loaded based on the digest but
> just to uniquely identify loaded programs from user space and match up
> with their source.

Okay, so in that case, a weak hashing function like SHA1 could result
in a real vulnerability. Therefore, this SHA1 stuff needs to be
reverted immediately, pending a different implementation. If this has
ever shipped in a kernel version, it could even deserve a CVE. No
SHA1!

> The hashing is not a proper sha1 neither, unfortunately. I think that
> is why it will have a custom implementation in iproute2?

Jeepers creepers. So for some ungodly reason, LKML has invented yet
another homebrewed crypto primitive. This story really gets more
horrifying every day. No bueno.

So yea, let's revert and re-commit (repeal and replace? just
kidding...). Out with SHA-1, in with Blake2 or SHA2.

Jason
