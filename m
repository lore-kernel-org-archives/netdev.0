From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 2.6] ixgb: fix ixgb_intr looping checks
Date: Wed, 10 Nov 2004 17:51:47 +0000 (UTC)
Message-ID: <Pine.LNX.4.44.0411101712080.16936-100000@localhost.localdomain>
References: <20041108151048.4bf605c1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041108151048.4bf605c1.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Nov 2004, Andrew Morton wrote:
> > This patch undoes a change that we believe will impact performance
> adversely,
> > by creating possibly too long a delay between servicing completions.
>=20
> Maybe.=A0 But now take a look at how much additional pointless work wil=
l be
> done in the common case.=A0 For instance, every tx completion will incu=
r a
> call to ixgb_clean_rx_irq(), which then calls ixgb_alloc_rx_buffers().

Is your common case transmits only? It seems there will always be more
than just one transmit and one receive to service in an interrupt.  The
issue with the current code is that the inner functions can loop
(clean_[tx|rx]) over many packets on their own, so I describe the current
code a little differently: "every group of tx completions, will then make
sure to call clean_rx to balance tx/rx work."  The way that you proposed
seems as if it may starve one side or the other if there are many packets
going in one direction. If I'm missing something let me know.

> There's quite a bit which can be optimised here.

Appreciate your input Andrew, currently we're just trying to keep the
e1000 and ixgb drivers the same, however it is possible that your solutio=
n
is better.  We are going to do a little experiment here over the next
couple of days to try performance with both your suggestion and with our
old method.  We'll reply with our results.

Jesse
