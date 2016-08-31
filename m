From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 21:40:02 +0200
Message-ID: <6677659.qx4okry02K@wuerfel>
References: <20160831123911.3467676-2-arnd@arndb.de> <20160831123911.3467676-1-arnd@arndb.de> <31015.1472665144@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <31015.1472665144@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 31, 2016 6:39:04 PM CEST David Howells wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > gcc -Wmaybe-initialized correctly points out a newly introduced bug
> > through which we can end up calling rxrpc_queue_call() for a dead
> > connection:
> 
> How do you turn that on from within the Kbuild system?

You don't, my mistake. My build bot runs with 6e8d666e9253 ("Disable
"maybe-uninitialized" warning globally") disabled, and I had
assumed that Linus left the warning enabled with "make W=1", but
that was incorrect as Trond Myklebust also pointed out.

You still get the warning with "make EXTRA_CFLAGS=-Wmaybe-uninitialized",
which of course nobody normally does.

I'll try to come up with a patch to enable the warning in the W=1
level in the same conditions that used to be enabled up to v4.7.

	Arnd
