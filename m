From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Date: Thu, 24 Mar 2016 15:22:38 +0100
Message-ID: <1458829358.9304.2.camel@sipsolutions.net>
References: <20160317164546.GT21104@mtj.duckdns.org>
	 <20160317213216.731d1fcc@synchrony.poochiereds.net>
	 <20160318204623.GM20028@mtj.duckdns.org>
	 <20160318212405.GA5192@fieldses.org>
	 <20160320185507.GT20028@mtj.duckdns.org>
	 (sfid-20160320_195510_233358_7162AE83)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Amitoj Kaur Chawla <amitoj1606-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	kernel-team-b10kYP2dOMg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160320185507.GT20028-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org> (sfid-20160320_195510_233358_7162AE83)
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-03-20 at 14:55 -0400, Tejun Heo wrote:
> If everything else is working, I'd be happy to throw in
> WQ_MEM_RECLAIM but I really don't want to add it if it doesn't
> actually achieve the goal.=C2=A0=C2=A0Can a wireless person chime in =
here?
>=20

I think for many wireless devices the workqueue, like for iwldvm that
was just changed, isn't in the packet path and thus less relevant.

=46or some, like SDIO based chips, it's more likely to be in the packet
path, so it would make sense to keep it.

Of course there's always a possibility of getting disconnected and then
not being able to re-establish the connection in memory pressure, but
that's not something we can control/predict (the disconnection). Can of
course also happen with wired if somebody pulls out the cable, but it's
less reliant on memory allocations to get back to working there, I
guess :)

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
