From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on
	CONFIG_NET_CLS_ACT
Date: 29 Oct 2004 09:12:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099055561.1028.133.camel@jzny.localdomain>
References: <20041029002113.GY12289@postel.suug.ch>
	 <20041029102620.GH12289@postel.suug.ch>
	 <1099049980.1024.21.camel@jzny.localdomain>
	 <20041029115333.GK12289@postel.suug.ch>
	 <1099053306.1025.95.camel@jzny.localdomain>
	 <20041029125356.GM12289@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041029125356.GM12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 08:53, Thomas Graf wrote:

> What about the rate estimator and basic stats in pkt_act.h? tca_gen
> requires at least basic,queue and rate_est for me to compile.
> 

Ok. tca_gen sub for current stats. 
Also most of them have no use for the estimator. I suppose if you ifdef
in tca_gen, then thats fine. 

> > All actions call
> > qdisc_copy_stats calls in their stats dumpers. Replace that call with
> > the magic you have in the new stats dumping scheme.
> 
> That's a lot of duplicated code which could be avoided easly. It's
> only a cosmetic thing but I don't see any reason for duplicating code :->
> 
> So this would be my way of doing it:
> 
> tcf_action_copy_stats {
>   start_copy()
>   copy_basic_stats()
>   copy_queue_stats()
>   copy_rate_est()
>   call get_stats() and let the action module dump additional stats
>   finish_copy
> }
> 

Good idea.

> I'd also suggest to make a new TLV type TCA_ACT_STATS and not reuse
> TCA_STATS.
> 

Fine by me.

> Another issue... do we want the compatibility stuff and provide the
> old tc_stats? I'd say no but it's your call.
> 

no need for backward compat here. We have an opportunity since its not
widely deployed. I wont feel sorry for any apps that somehow depend on
old stats.

cheers,
jamal

PS:- iproute2 patch needed.
PPS:- I hope all the actions i queued to Dave are in ;->
