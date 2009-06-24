From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: Re: [PATCH 03/10] mac80211: Use rcu_barrier() on unload.
Date: Wed, 24 Jun 2009 13:32:17 +0200
Message-ID: <1245843137.6695.48.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150409.22490.99106.stgit@localhost>
	 <1245770155.21314.38.camel@johannes.local>
	 <1245837965.6695.45.camel@localhost.localdomain>
	 <1245838862.21314.48.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bluesmoke-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1245838862.21314.48.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-06-24 at 12:21 +0200, Johannes Berg wrote:
> On Wed, 2009-06-24 at 12:06 +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 2009-06-23 at 17:15 +0200, Johannes Berg wrote:
> > > On Tue, 2009-06-23 at 17:04 +0200, Jesper Dangaard Brouer wrote:
> > > > The mac80211 module uses rcu_call() thus it should use rcu_barrier()
> > > > on module unload.
> > > > 
> > > > I'm having a hardtime verifying that no more call_rcu() callbacks can
> > > > be schedules in the module unload path.  Could a maintainer please
> > > > look into this?
> > > > 
> > > > Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
> > > > ---
> > > > 
> > > >  net/mac80211/main.c |    2 ++
> > > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> > > > index 092a017..e9f70ce 100644
> > > > --- a/net/mac80211/main.c
> > > > +++ b/net/mac80211/main.c
> > > > @@ -1100,6 +1100,8 @@ static void __exit ieee80211_exit(void)
> > > >  		ieee80211s_stop();
> > > >  
> > > >  	ieee80211_debugfs_netdev_exit();
> > > > +
> > > > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> > > >  }
> > > 
> > > I don't think this is correct at all -- note that call_rcu() is done in
> > > some of the mesh code, so I would think you need to do this in
> > > ieee80211_stop() since the call_rcu() code requires the interface to
> > > still be around. And when it's stopped everything should be idle.
> > 
> > Should it then not be in mesh.c ieee80211_stop_mesh().  We can replace
> > the synchronize_rcu() in this function with a rcu_barrier().
> 
> Yes, this seems correct.
> 
> johannes

Can I consider this a:

Acked-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

???

DaveM seems to like this as patchwork.ozlabs.org picks up this
automatically...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
