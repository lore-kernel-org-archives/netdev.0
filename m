From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on
	CONFIG_NET_CLS_ACT
Date: 29 Oct 2004 08:35:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099053306.1025.95.camel@jzny.localdomain>
References: <20041029002113.GY12289@postel.suug.ch>
	 <20041029102620.GH12289@postel.suug.ch>
	 <1099049980.1024.21.camel@jzny.localdomain>
	 <20041029115333.GK12289@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041029115333.GK12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 07:53, Thomas Graf wrote:
> * jamal <1099049980.1024.21.camel@jzny.localdomain> 2004-10-29 07:39
> > Thomas, Can you submit equivalent patches for cls_u32.c?
> 
> Sure, already done and queued for submission. I will submit them today.
> 

Ok, that will be good because it will help do a one shot test on bk.

> Regarding the generic statistics for actions:
> 
> I thought about dumping the most common stats basic,queue,rate_est
> in tcf_action_copy_stats and let the action module dump additional
> stats in its get_stats implementation. 

I think the action code seems clean to me as is.
Here are my thoughts:
Most of them just need queue stats (actually at the moment all of them)
so in tca_gen, struct tc_stats stats needs replacement to make sure they
only have a queue stat because it is generic. All actions call
qdisc_copy_stats calls in their stats dumpers. Replace that call with
the magic you have in the new stats dumping scheme. I think the same
lock can be used for all stats in an action (if new ones are added by an
action).

> Any objections in creating
> struct tca_act_gen with the content of tca_gen and use it to
> access a->priv from act_api.c to get my hands on the statistics
> and stats_lock?

Refer to above.

cheers,
jamal

PS:- I hope this is after the bk snapshot with current cleanups you have
is tested?
