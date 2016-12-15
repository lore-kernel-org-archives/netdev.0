From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Re: [PATCH 4/3] random: use siphash24 instead
 of md5 for get_random_int/long
Date: Thu, 15 Dec 2016 02:19:08 +0100
Message-ID: <CAHmME9qZqEWDOcqPggZW7KBrTz3tPnWz+gyjaj=rO0O_69BtyQ@mail.gmail.com>
References: <20161214001656.19388-1-Jason@zx2c4.com> <20161214031037.25498-1-Jason@zx2c4.com>
 <20161214163731.luj2dzmnihcuhn5p@thunk.org> <CAHmME9o3uQoi5h=YTKB=5yN1yzz=d3=GFjGiXv_Sf12kAsjx3A@mail.gmail.com>
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
Return-path: <kernel-hardening-return-5565-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9o3uQoi5h=YTKB=5yN1yzz=d3=GFjGiXv_Sf12kAsjx3A@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hey Ted,

On Wed, Dec 14, 2016 at 8:12 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> I think this opens up a big window for optimizing it even
> further.

I optimized it a bit further and siphash is now the clear winner over chacha:

[    1.784801] random benchmark!!
[    1.785161] get_random_long # cycles: 415983
[    1.785595] get_random_long_chacha # cycles: 242047
[    1.785997] get_random_long_siphash # cycles: 137130
[    1.787450] get_random_bytes # cycles: 1452985
[    1.787947] get_random_int # cycles: 343323
[    1.788282] get_random_int_chacha # cycles: 170767
[    1.788656] get_random_int_siphash # cycles: 86384
[    1.789764] get_random_bytes # cycles: 2279519

And even still, there is more that could be optimized. Therefore, I'll
continue to keep this patch in the series and will CC you on the next
patch set that goes out.

Jason
