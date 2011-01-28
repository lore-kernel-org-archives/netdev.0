From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 2/2] net/netlabel: Avoid call to genlmsg_cancel
Date: Fri, 28 Jan 2011 16:29:06 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101281628361.8546@pc-004.diku.dk>
References: <1296224232-8115-2-git-send-email-julia@diku.dk>
 <1296225364.5511.6.camel@sifl>  <Pine.LNX.4.64.1101281541030.8546@pc-004.diku.dk>
 <1296228218.5511.13.camel@sifl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296228218.5511.13.camel@sifl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2011, Paul Moore wrote:

> On Fri, 2011-01-28 at 15:58 +0100, Julia Lawall wrote:
> > On Fri, 28 Jan 2011, Paul Moore wrote:
> > 
> > > On Fri, 2011-01-28 at 15:17 +0100, Julia Lawall wrote:
> > > > genlmsg_cancel subtracts some constants from its second argument before
> > > > calling nlmsg_cancel.  nlmsg_cancel then calls nlmsg_trim on the same
> > > > arguments.  nlmsg_trim tests for NULL before doing any computation, but a
> > > > NULL second argument to genlmsg_cancel is no longer NULL due to the initial
> > > > subtraction.  Nothing else happens in this execution, so the call to
> > > > genlmsg_cancel is simply unnecessary in this case.
> > > > 
> > > > The semantic match that finds this problem is as follows:
> > > > (http://coccinelle.lip6.fr/)
> > > > 
> > > > // <smpl>
> > > > @@
> > > > expression data;
> > > > @@
> > > > 
> > > > if (data == NULL) { ...
> > > > * genlmsg_cancel(..., data);
> > > >   ...
> > > >   return ...;
> > > > }
> > > > // </smpl>
> > > > 
> > > > Signed-off-by: Julia Lawall <julia@diku.dk>
> > > 
> > > In all of the cases below, these functions are called multiple times to
> > > generate data chunks (additional netlink attributes) which are appended
> > > to an existing skbuff.  I believe that the calls to genlmsg_cancel() are
> > > still needed to help cleanup in the case where the functions fail on the
> > > Nth call.
> > > 
> > > If I'm wrong, feel free to enlighten me.
> > 
> > Perhaps something is needed, but I don't see how the current code can 
> > work.  The call is genlmsg_cancel(cb_arg->skb, NULL) in each case.
> 
> Ah yes, you're right.  You will have to forgive me as it has been quite
> a while since I have looked at NetLabel's netlink code.
> 
> You also might consider putting a NULL check in genlmsg_cancel() similar
> to the check nlmsg_trim(); that seems like a worthwhile addition.

OK, I'll do that.

julia
