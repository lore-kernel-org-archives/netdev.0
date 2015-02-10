From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 13:26:06 -0800
Message-ID: <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
	<CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
	<CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 8:58 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Feb 10, 2015 at 8:33 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Will try your suggestion,
>
> Nope, that wasn't it. It still hangs in the same place (I forgot to
> get rid of the red hat graphical boot screen so I didn't see the oops,
> but ..)

Just to confirm that yes, it's that particular commit 1d10eb2f156f.

I reverted it and things work again. So it's not the miscalculation of
"used" , but it's certainly *something* in that commit.

Oh well. I have a ton of other trees to pull, so I'll just drop this for now.

> Looking more closely at the generated code, and the fact that the oops
> was an access at offset 0x18 from a NULL pointer, it would *look* like
> it's this instruction:
>
>         call    *24(%rax)       # MEM[(struct ablkcipher_tfm *)_48 + 8B].decrypt

Double-checked, and yes, "skcipher_recvmsg+0x360/0x410" is that call
to the decrypt routine.

So it looks like for some reason that

    struct ablkcipher_tfm *crt =
        crypto_ablkcipher_crt(crypto_ablkcipher_reqtfm(req));;

ends up being NULL in

     crypto_ablkcipher_decrypt(&ctx->req)

causing the oops.  I just don't see what the heck in that patch would
have changed any of that.

                        Linus
