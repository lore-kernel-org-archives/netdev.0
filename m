From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Re: [PATCH 4/3] random: use siphash24 instead
 of md5 for get_random_int/long
Date: Wed, 14 Dec 2016 20:12:14 +0100
Message-ID: <CAHmME9o3uQoi5h=YTKB=5yN1yzz=d3=GFjGiXv_Sf12kAsjx3A@mail.gmail.com>
References: <20161214001656.19388-1-Jason@zx2c4.com> <20161214031037.25498-1-Jason@zx2c4.com>
 <20161214163731.luj2dzmnihcuhn5p@thunk.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com, "Theodore Ts'o" <tytso@mit.edu>,
	"Jason A. Donenfeld" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, George Spelvin <linux@horizon.com>,
	Scott Bauer <sbauer@eng.utah.edu>, Andi Kleen <ak@linux.intel.com>,
	Andy Lutomirski <luto@amacapital.net>, Greg KH <gregkh@linuxfoundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5533-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161214163731.luj2dzmnihcuhn5p@thunk.org>
List-Id: netdev.vger.kernel.org

Hi again,

On Wed, Dec 14, 2016 at 5:37 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> [    3.606139] random benchmark!!
> [    3.606276] get_random_int # cycles: 326578
> [    3.606317] get_random_int_new # cycles: 95438
> [    3.607423] get_random_bytes # cycles: 2653388

Looks to me like my siphash implementation is much faster for
get_random_long, and more or less tied for get_random_int:

[    1.729370] random benchmark!!
[    1.729710] get_random_long # cycles: 349771
[    1.730128] get_random_long_chacha # cycles: 359660
[    1.730457] get_random_long_siphash # cycles: 94255
[    1.731307] get_random_bytes # cycles: 1354894
[    1.731707] get_random_int # cycles: 305640
[    1.732095] get_random_int_chacha # cycles: 80726
[    1.732425] get_random_int_siphash # cycles: 94265
[    1.733278] get_random_bytes # cycles: 1315873

Given the increasing usage of get_random_long for ASLR and related, I
think this makes the siphash approach worth pursuing. The chacha
approach is also not significantly different from the md5 approach in
terms of speed for get_rand_long. Additionally, since siphash is a
PRF, I think this opens up a big window for optimizing it even
further.

Benchmark here:
    https://git.zx2c4.com/linux-dev/commit/?h=rng-bench

Jason
