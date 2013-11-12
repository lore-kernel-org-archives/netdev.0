From: Karl Beldan <karl.beldan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and
 call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 01:37:09 +0100
Message-ID: <20131112003709.GA11824@gobelin>
References: <cover.1384160397.git.dborkman@redhat.com>
 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
 <20131111134357.GC10104@thunk.org>
 <20131112000307.GB14929@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131112000307.GB14929-5j1vdhnGyZutBveJljeh2VPnkB77EeZ12LY78lusg7I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 01:03:07AM +0100, Hannes Frederic Sowa wrote:
> On Mon, Nov 11, 2013 at 08:43:57AM -0500, Theodore Ts'o wrote:
> > On Mon, Nov 11, 2013 at 12:20:34PM +0100, Daniel Borkmann wrote:
> > > From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
> > > 
> > > The Tausworthe PRNG is initialized at late_initcall time. At that time the
> > > entropy pool serving get_random_bytes is not filled sufficiently. This
> > > patch adds an additional reseeding step as soon as the nonblocking pool
> > > gets marked as initialized.
> > > 
> > > On some machines it might be possible that late_initcall gets called after
> > > the pool has been initialized. In this situation we won't reseed again.
> > > 
> > > (A call to prandom_seed_late blocks later invocations of early reseed
> > > attempts.)
> > > 
> > > Joint work with Daniel Borkmann.
> > 
> > Acked-by: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
> > 
> > I wasn't cc'ed on the full series (I didn't see the 0/3 or the 4/6
> > messages) but there are two other things that you might want to
> > consider.
> > 
> > 1)  I'm pretty sure, but it would be good to get netdev confirmation,
> > that the call to get_random_bytes() in
> > net/mac80211/rc80211_minstrel.c's init_sample_table() can be replaced
> > by calls to prandom_u32().
> 
> Would make sense. I added wireless-devel to confirm.
> 
> [...]
> [    0.673260] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.674024] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.675012] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.676032] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.677020] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.678011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [    0.679011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> [...]
> 
> In total 80 calls to get_random_bytes.
> 

It is already 8 times what rc80211_minstrel_ht_init uses.
If you could apply on top of:
http://marc.info/?l=linux-wireless&m=138392850030987&w=2
although Johannes has not yet agreed/applied this.

 
Karl
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
