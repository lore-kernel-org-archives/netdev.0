From: "David S. Miller" <davem@davemloft.net>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 13:12:59 -0700
Message-ID: <20050405131259.4b00b8de.davem@davemloft.net>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
	<20050405123438.28f02423.davem@davemloft.net>
	<Pine.LNX.4.58.0504051238390.14264@server.graphe.net>
	<20050405125014.1ce46c66.davem@davemloft.net>
	<Pine.LNX.4.58.0504051252280.14264@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
In-Reply-To: <Pine.LNX.4.58.0504051252280.14264@server.graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Apr 2005 12:58:15 -0700 (PDT)
Christoph Lameter <christoph@lameter.com> wrote:

> On Tue, 5 Apr 2005, David S. Miller wrote:
> 
> > > I fail to see what the point of having a single instance of
> > > atomic_dec_and_test for __refcnt is. In particular since the upper layers
> > > guarantee that dst_destroy is not called multiple times for the same dst
> > > entry.
> >
> > If this is true, what performance improvement could you possibly be
> > seeing from this change?
> 
> We could make refcnt into an array of pointers that point to node specific
> memory. This avoids cache line bouncing. However, you cannot atomically
> dec_and_test an array. This is the only location where a dec_and_test is
> used on dst->__refcnt.

The dst object is already too large.  You have to show a serious
performance improvement to justify bloating it up further.

> We can put an explicit barier in if that is the only reason for the
> atomic_dec_and_test.

Then we lose the optimizations of those memory barriers that platforms
do in their atomic_op assembly.

Let me check out if your assertions about dst_destroy() usage are correct
first, hold on for a bit.
