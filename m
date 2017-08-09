From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed, 09 Aug 2017 16:45:47 +0100
Message-ID: <29920.1502293547@warthog.procyon.org.uk>
References: <CAK8P3a2STbhgFB5kbVTZqAgY70K_GCaWgj6Kqs4RJOOt2oSd-g@mail.gmail.com> <cover.1502246501.git.baolin.wang@linaro.org> <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org> <CAK8P3a2WU5uYddGrkWhyfNB4qTEDYne_pyCVG6n5b1w+vb1-OQ@mail.gmail.com> <6767.1502271233@warthog.procyon.org.uk> <CAK8P3a3L11rXAV8-hE1fNtAZyMBNnQneRm5g7F8VDmk7HjQV4A@mail.gmail.com> <11686.1502285205@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, Baolin Wang <baolin.wang@linaro.org>,
        David Miller <davem@davemloft.net>, james.l.morris@oracle.com,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Mark Brown <broonie@kernel.org>, keyrings@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2STbhgFB5kbVTZqAgY70K_GCaWgj6Kqs4RJOOt2oSd-g@mail.gmail.com>
Content-ID: <29919.1502293547.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> Ah, I'm slowly starting to understand how this fits together. So you can add
> a key either through key_add() from local user space, or through an rxrpc
> socket.

No, you can't add keys through an rxrpc socket.

There are three 'classes' of key:

 (1) Client keys (type rxrpc).  These must be added by add_key() by userspace
     (but could also be acquired by upcalling to /sbin/request-key) and then
     the kernel calls request_key() to locate them on entry through either a
     kafs inode/file operation or through sendmsg() to an AF_RXRPC socket.

 (2) Server keys (type rxrpc_s).  These are created by userspace and are
     presented to an AF_RXRPC server socket by calling setsockopt().  The
     server uses these to validate/decrypt the token passed by a RESPONSE
     packet.

 (3) Service connection keys (type rxrpc).  These are created internally by
     AF_RXRPC after a successful challenge/response negotiation to hold the
     security details so that we have a struct key to pass around that
     corresponds to the key in (1).

David
