From: Willy Tarreau <w@1wt.eu>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 15:15:40 +0200
Message-ID: <20120714131540.GQ16256@1wt.eu>
References: <20120713171835.GA26052@vault.local> <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com> <1342254042.3265.9017.camel@edumazet-glaptop> <20120714083136.GO16256@1wt.eu> <20120714101321.GA26329@vault.local> <1342262004.3265.9279.camel@edumazet-glaptop> <20120714104441.GP16256@1wt.eu> <1342263967.3265.9347.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Truschnigg <johannes@truschnigg.info>,
	Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org,
	Linux-Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342263967.3265.9347.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 14, 2012 at 01:06:07PM +0200, Eric Dumazet wrote:
> On Sat, 2012-07-14 at 12:44 +0200, Willy Tarreau wrote:
> > On Sat, Jul 14, 2012 at 12:33:24PM +0200, Eric Dumazet wrote:
> > > On Sat, 2012-07-14 at 12:13 +0200, Johannes Truschnigg wrote:
> > > > On Sat, Jul 14, 2012 at 10:31:36AM +0200, Willy Tarreau wrote:
> > > > > > Please Johannes could you try latest kernel tree ?
> > > > > 
> > > > > It would be useful, especially given the amount of changes you performed
> > > > > in this area in latest version, it could be very possible that this new
> > > > > bug got fixed as a side effect !
> > > > 
> > > > I upgraded to 3.4.4 (identical config as the 3.4.0 build I've been running)
> > > > and what can I say - the problem really seems to have disappeared. I performed
> > > > about 3700 iterations of my previos tests over the night, and the data always
> > > > turned out to be OK, not a single byte turned out kaput!
> > > > 
> > > > I wish I would have tested that earlier, and spared you the noise... well,
> > > > maybe someone who runs into a similar problem in the future will have this
> > > > discovery save her/him some time and headaches and make her/him just upgrade
> > > > kernels :)
> > > > 
> > > > Thanks a lot for your polite and quick responses!
> > > > 
> > > 
> > > Nice to hear. Now we should make sure we have all needed fixes for prior
> > > stable kernels as well !
> > > 
> > > Still trying to understand the issue, since I thought I only did
> > > optimizations, not bug fixes. So maybe real bug is still there but its
> > > probability of occurrence lowered enough to not hit your workload.
> > 
> > Please note that Johannes tested 3.4.4 while your changes are in 3.5-rc.
> > 
> > I'm wondering whether this patch merged into 3.4.2 one has an impact on
> > sendfile :
> > 
> >   commit b642cb6a143da812f188307c2661c0357776a9d0
> >   Author: Konstantin Khlebnikov <khlebnikov@openvz.org>
> >   Date:   Tue Jun 5 21:36:33 2012 +0400
> > 
> >     radix-tree: fix contiguous iterator
> >     
> >     commit fffaee365fded09f9ebf2db19066065fa54323c3 upstream.
> >     
> >     This patch fixes bug in macro radix_tree_for_each_contig().
> >     
> >     If radix_tree_next_slot() sees NULL in next slot it returns NULL, but following
> >     radix_tree_next_chunk() switches iterating into next chunk. As result iterating
> >     becomes non-contiguous and breaks vfs "splice" and all its users.
> > 
> > Willy
> > 
> 
> 
> Hmmm, this is supposed to fix a bug introduced in 3.4, no ?
> 
> So 3.3 kernel should work well ?

You're right indeed. So maybe it's not the same bug. Or maybe Johannes
was affected by two different bugs in both versions, since Thorsten's
report seems to point the finger at the same bug.

Johannes, are you certain that you were having the exact same issue
with 3.3 ?

Willy
