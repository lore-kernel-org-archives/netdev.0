From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on CONFIG_NET_CLS_ACT
Date: Fri, 29 Oct 2004 14:53:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029125356.GM12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch> <20041029102620.GH12289@postel.suug.ch> <1099049980.1024.21.camel@jzny.localdomain> <20041029115333.GK12289@postel.suug.ch> <1099053306.1025.95.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099053306.1025.95.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Regarding the generic statistics for actions:
> > 
> > I thought about dumping the most common stats basic,queue,rate_est
> > in tcf_action_copy_stats and let the action module dump additional
> > stats in its get_stats implementation. 
> 
> I think the action code seems clean to me as is.
> Here are my thoughts:
> Most of them just need queue stats (actually at the moment all of them)
> so in tca_gen, struct tc_stats stats needs replacement to make sure they
> only have a queue stat because it is generic.

What about the rate estimator and basic stats in pkt_act.h? tca_gen
requires at least basic,queue and rate_est for me to compile.

> All actions call
> qdisc_copy_stats calls in their stats dumpers. Replace that call with
> the magic you have in the new stats dumping scheme.

That's a lot of duplicated code which could be avoided easly. It's
only a cosmetic thing but I don't see any reason for duplicating code :->

So this would be my way of doing it:

tcf_action_copy_stats {
  start_copy()
  copy_basic_stats()
  copy_queue_stats()
  copy_rate_est()
  call get_stats() and let the action module dump additional stats
  finish_copy
}

I'd also suggest to make a new TLV type TCA_ACT_STATS and not reuse
TCA_STATS.

Another issue... do we want the compatibility stuff and provide the
old tc_stats? I'd say no but it's your call.

> PS:- I hope this is after the bk snapshot with current cleanups you have
> is tested?

Sure. Always planning ahead.
