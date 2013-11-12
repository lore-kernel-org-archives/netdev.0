From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and
 call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 09:36:15 +0100
Message-ID: <1384245375.14301.1.camel@jlt4.sipsolutions.net>
References: <cover.1384160397.git.dborkman@redhat.com>
	 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
	 <20131111134357.GC10104@thunk.org>
	 <20131112000307.GB14929@order.stressinduktion.org>
	 <20131112003709.GA11824@gobelin> (sfid-20131112_013733_866376_8AB7C8FE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Karl Beldan <karl.beldan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131112003709.GA11824@gobelin> (sfid-20131112_013733_866376_8AB7C8FE)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-12 at 01:37 +0100, Karl Beldan wrote:

> > > 1)  I'm pretty sure, but it would be good to get netdev confirmation,
> > > that the call to get_random_bytes() in
> > > net/mac80211/rc80211_minstrel.c's init_sample_table() can be replaced
> > > by calls to prandom_u32().
> > 
> > Would make sense. I added wireless-devel to confirm.
> > 
> > [...]
> > [    0.673260] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.674024] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.675012] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.676032] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.677020] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.678011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [    0.679011] random: rc80211_minstrel_ht_init+0x47/0xaa get_random_bytes called with 3 bits of entropy available
> > [...]
> > 
> > In total 80 calls to get_random_bytes.
> > 
> 
> It is already 8 times what rc80211_minstrel_ht_init uses.
> If you could apply on top of:
> http://marc.info/?l=linux-wireless&m=138392850030987&w=2
> although Johannes has not yet agreed/applied this.

I'll take the patch, I just wanted a more useful commit log :)

I guess if really needed I'll write that myself :(

Anyway, I can't comment on prandom_u32(), but it doesn't really have to
be all that random here, it's just sample tables for what order to try
things in. Technically that could even be static with some per-device
pertubation, I guess?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
