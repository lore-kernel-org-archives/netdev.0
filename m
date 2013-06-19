From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] nl80211: fix attrbuf access race by allocating a
 separate one
Date: Wed, 19 Jun 2013 09:51:35 -0400
Message-ID: <20130619135134.GA12079@tuxdriver.com>
References: <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
 <1371628488.8349.3.camel@jlt4.sipsolutions.net>
 <1371630238.8349.6.camel@jlt4.sipsolutions.net>
 <20130619.013900.786603036908799505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130619.013900.786603036908799505.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 01:39:00AM -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Wed, 19 Jun 2013 10:23:58 +0200
> 
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > 
> > Since my commit 3713b4e364, nl80211_dump_wiphy() uses the global
> > nl80211_fam.attrbuf for parsing the incoming data. This wouldn't
> > be a problem if it only did so on the first dump iteration which
> > is locked against other commands in generic netlink, but due to
> > space constraints in cb->args (the needed state doesn't fit) I
> > decided to always parse the original message. That's racy though
> > since nl80211_fam.attrbuf could be used by some other parsing in
> > generic netlink concurrently.
> > 
> > For now, fix this by allocating a separate parse buffer (it's a
> > bit too big for the stack, currently 1448 bytes on 64-bit). For
> > -next, I'll change the code to parse into the global buffer in
> > the first round only and then allocate a smaller buffer to keep
> > the state in cb->args.
> > 
> > Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Acked-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
