From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 2/3] mac80211: mesh: improve path resolving time
Date: Thu, 11 Aug 2016 15:22:12 +0200
Message-ID: <1470921732.12075.18.camel@sipsolutions.net>
References: <20160713114528.24835-1-yanivma@ti.com>
	 <20160719123648.GC11996@localhost> (sfid-20160719_143659_093323_398D42D9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Maital Hahn <maitalm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Bob Copeland <me@bobcopeland.com>, Yaniv Machani <yanivma@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719123648.GC11996@localhost> (sfid-20160719_143659_093323_398D42D9)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-19 at 08:36 -0400, Bob Copeland wrote:
> On Wed, Jul 13, 2016 at 02:45:25PM +0300, Yaniv Machani wrote:
> > 
> > When a packet is received for transmission,
> > a PREQ frame is sent to resolve the appropriate path to the desired
> > destination.
> > After path was established, any sequential PREQ will be sent only
> > after
> > dot11MeshHWMPpreqMinInterval, which usually set to few seconds.
> > 
> > This implementation has an impact in cases where we would like to
> > resolve the path quickly.
> > A clear example is when a peer was disconnected from us,
> > while he acted as a hop to our destination.
> > Although the path table will be cleared, the next PREQ frame will
> > be sent only after reaching the MinInterval.
> > This will cause unwanted delay, possibly of few seconds until the
> > traffic will resume.
> > 
> >  	if (!(mpath->flags & MESH_PATH_RESOLVING))
> > -		mesh_queue_preq(mpath, PREQ_Q_F_START);
> > +		mesh_queue_preq(mpath, PREQ_Q_F_START, true);
> 
> What about something like this here instead:
> 
>     if (!(mpath->flags & MESH_PATH_RESOLVING)) {
>         /* force next preq to be sent without delay */
>         ifmsh->last_preq = jiffies - min_preq_int_jiff(sdata) - 1;
>         mesh_queue_preq(mpath, PREQ_Q_F_START);
>     }
> 

Yaniv, did you disagree with this for some strong reason, or were you
going to resend?

Having a smaller patch seems nicer too.

johannes
