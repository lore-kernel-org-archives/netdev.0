From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: [PATCH 2/4] mac80211/cfg: mesh: fix healing time when a mesh
 peer is disconnecting
Date: Tue, 28 Jun 2016 14:43:00 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391D51E6@DFRE01.ent.ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com> <20160628122747.GA7757@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hahn, Maital" <maitalm@ti.com>
To: Bob Copeland <me@bobcopeland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628122747.GA7757@localhost>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 15:27:47, Bob Copeland wrote:
> linux- wireless@vger.kernel.org; netdev@vger.kernel.org; Hahn, Maital
> Subject: Re: [PATCH 2/4] mac80211/cfg: mesh: fix healing time when a 
> mesh peer is disconnecting
> 
> On Tue, Jun 28, 2016 at 02:13:05PM +0300, Yaniv Machani wrote:
> > From: Maital Hahn <maitalm@ti.com>
> >
> > Once receiving a CLOSE action frame from the disconnecting peer, 
> > flush all entries in the path table which has this peer as the next hop.
> 
> Please address the user-visible behavior in your commit messages.
> Does it crash?  Does it send frames to an invalid peer?  Do frames get dropped?
> 

Hi Bob,
It was a crash, apparently already fixed by your patches some time ago.
I'll remove that part and resend the 2nd part (with some more 'why', and less typos..)

> > In addition, upon receiving a packet, if next hop is not found, 
> > trigger PERQ immidiatly, instead of just putting it in the queue.
> 
> "PREQ"
> 
> Please split this into a separate patch that we can review separately 
> (and also give the "why" in the commit log).
> 
> > @@ -1011,6 +1011,7 @@ static void sta_apply_mesh_params(struct
> ieee80211_local *local,
> >  			if (sta->mesh->plink_state == NL80211_PLINK_ESTAB)
> >  				changed =
> mesh_plink_dec_estab_count(sdata);
> >  			sta->mesh->plink_state = params->plink_state;
> > +			mesh_path_flush_by_nexthop(sta);
> 
> This isn't necessary, caller should already be doing
> mesh_path_flush_by_nexthop() in every case I could see.  Besides it 
> cannot be done under plink lock.
> 

I believe this was fixed in your patch "mac80211: mesh: flush paths outside of plink lock"
There is probably no need in that on the latest as well.

Thanks,
Yaniv
 
