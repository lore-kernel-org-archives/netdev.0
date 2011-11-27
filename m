From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
 components.
Date: Sun, 27 Nov 2011 13:00:20 -0500
Message-ID: <1322416820.7338.42.camel@mojatatu>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu>
	<E521938A-E5E5-48CE-B784-6BF38ED274AE@nicira.com>
	<1322141102.1949.198.camel@mojatatu>
	<198A6700-6BB3-4639-A2AC-C306DFB24CE0@nicira.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <198A6700-6BB3-4639-A2AC-C306DFB24CE0-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-11-26 at 23:17 -0800, Justin Pettit wrote:

> 
> You're right--calling tc directly through system() is kind of ugly.
> That code was written a *long* time ago when we wanted a quick QoS story.
> As you mentioned, we use netlink to configure traffic shaping, so we have
> all the pieces at this point.  I just think no one ever bothered to clean
> up that little wart in userspace.  

Understandable.  You shipped something that works.

I guess the point i was trying to make is you _are_ already using
the classifier action subsystem. You have the u32 classifier and
the policer action. You should just introduce a new classifier
and the 2 or so actions you need and other folks can benefit from
them as well without need to use openvswitch.

> We encourage users to use shaping, since it generally provides 
> better results (and we do expose per-flow granularity there).  
> As a result, we haven't seen a need to improve support for policing.

HTB's metering algorithm was essentially originally ripped off the
policer action; probably better off for TCP to use shaping hence the
results you are observing.

cheers,
jamal
