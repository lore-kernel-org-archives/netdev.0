From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 12:47:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504051238390.14264@server.graphe.net>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
 <20050405123438.28f02423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050405123438.28f02423.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005, David S. Miller wrote:

> On Tue, 5 Apr 2005 11:55:45 -0700 (PDT)
> Christoph Lameter <christoph@lameter.com> wrote:
>
> > Is the atomic_dec_and_test in dst_destroy just there to join two atomic
> > operations into one without being necessary for the correctness of freeing
> > dsts?
> atomic_dec() has no memory ordering guarentees, only the atomic
> routines returning values do the proper SMP memory barriers.
> So, based upon this alone I don't think your change is valid.

Correct that applies in general. But what could go wrong if the atomic_dec
is separated from the atomic_read in this specific location?

I fail to see what the point of having a single instance of
atomic_dec_and_test for __refcnt is. In particular since the upper layers
guarantee that dst_destroy is not called multiple times for the same dst
entry.
