From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 13:46:05 +0100
Message-ID: <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161214035927.30004-1-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Dec 14, 2016 at 10:56 AM, David Laight <David.Laight@aculab.com> wrote:
> ...
>> +u64 siphash24(const u8 *data, size_t len, const u8 key[SIPHASH24_KEY_LEN])
> ...
>> +     u64 k0 = get_unaligned_le64(key);
>> +     u64 k1 = get_unaligned_le64(key + sizeof(u64));
> ...
>> +             m = get_unaligned_le64(data);
>
> All these unaligned accesses are going to get expensive on architectures
> like sparc64.

Yes, the unaligned accesses aren't pretty. Since in pretty much all
use cases thus far, the data can easily be made aligned, perhaps it
makes sense to create siphash24() and siphash24_unaligned(). Any
thoughts on doing something like that?

Jason
