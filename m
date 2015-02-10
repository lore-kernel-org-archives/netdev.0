From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 08:58:55 -0800
Message-ID: <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
	<CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 8:33 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Will try your suggestion,

Nope, that wasn't it. It still hangs in the same place (I forgot to
get rid of the red hat graphical boot screen so I didn't see the oops,
but ..)

Looking more closely at the generated code, and the fact that the oops
was an access at offset 0x18 from a NULL pointer, it would *look* like
it's this instruction:

        call    *24(%rax)       # MEM[(struct ablkcipher_tfm *)_48 + 8B].decrypt

in the asm. Very odd. That part doesn't seem to have changed at all
(it's the crypto_ablkcipher_decrypt() part inside the
af_alg_wait_for_completion call).

Ignoring whitespace changes and doing a

    git show -w 1d10eb2f156f crypto/algif_skcipher.c

does make it clear that apart from the "iter" changes, the only real
difference seems to be to the usage of "used". But I can't judge the
iter changes. And maybe something else changed elsewhere.

Any other ideas? Al?

                       Linus
