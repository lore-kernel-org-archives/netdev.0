From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] carl9170: Remove redundant protection check
Date: Fri, 22 Aug 2014 23:53:40 +0200
Message-ID: <1931285.KsvFbLZH2Q@debian64>
References: <20140822191431.GA5827@ada> <1679858.MgakDZE2Vr@debian64> <1408741732.5604.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andreea-Cristina Bernat <bernat.ada@gmail.com>,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408741732.5604.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, August 22, 2014 02:08:52 PM Eric Dumazet wrote:
> On Fri, 2014-08-22 at 22:38 +0200, Christian Lamparter wrote:
> [...]
> > From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
> > 
> > The carl9170_op_ampdu_action() function is used only by the mac80211
> > framework. Since the mac80211 already takes care of checks and 
> > properly serializing calls to the driver's function there is no
> > need for the driver to do the same thing.
> >  
> > ---
> > @@ -1430,18 +1430,10 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
> >  		if (!sta_info->ht_sta)
> >  			return -EOPNOTSUPP;
> >  
> > -		rcu_read_lock();
> > -		if (rcu_dereference(sta_info->agg[tid])) {
> > -			rcu_read_unlock();
> > -			return -EBUSY;
> > -		}
> > -
> > [...]
> > ---
> 
> Sorry but this patch is not complete.
> 
> You need to somehow return -EBUSY if sta_info->agg[tid] is set.
The sta_info->agg[tid] check is not needed (for reference, see [0]).
(There is already a check in mac80211 which prevents the leak of
sta_info->agg[tid] [1]).

Regards
Christian

[0] <https://lkml.org/lkml/2014/8/20/725>
[1] <http://lxr.free-electrons.com/source/net/mac80211/agg-tx.c#L583>
