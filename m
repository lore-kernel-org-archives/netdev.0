From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 9 Feb 2015 20:37:13 -0800
Message-ID: <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150209.191601.1373941323785500419.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 9, 2015 at 7:16 PM, David Miller <davem@davemloft.net> wrote:
>
> 1) More iov_iter conversion work from Al Viro.
> ...
>
> are available in the git repository at:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next

I pulled, but had to unpull.

This doesn't work for me AT ALL.

I get an oops early during boot (in "systemd-cryptse.." - it happens
immediately after typing in my disk encryption key so it's
possible/likely that you need an md-crypt setup to see this).

It's a NULL pointer derefernce (at offset 0x18) where the callchain
looks like this:

  RIP: skcipher_recvmsg+0x360/0x410
  Call Trace:
     sock_read_iter+0xd0/0x120
     new_sync_read+0x79/0xb0
     __vfs_read+0x13/0x50
     SyS_read+0x41/0x0b0
     system_call_fastpath

which I assume is related to the iov_iter conversion.

That oops then is followed immediately by another that is a NULL
pointer dereference in skcipher_sock_destruct, but the callchain for
that is just the exit as part of killing of the original oops, so that
second oops seems to be just a result of the first one.

I'm assuming the culrpit is 1d10eb2f156f ("crypto: switch
af_alg_make_sg() to iov_iter") but haven't tested.

Sorry for the lack of full dmesg, but the oops happens before the
system is actually usable, so I just have a camera screenshot of it.

Any ideas?

                              Linus
