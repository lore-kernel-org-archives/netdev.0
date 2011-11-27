From: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Sat, 26 Nov 2011 23:17:50 -0800
Message-ID: <198A6700-6BB3-4639-A2AC-C306DFB24CE0@nicira.com>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu>
	<E521938A-E5E5-48CE-B784-6BF38ED274AE@nicira.com>
	<1322141102.1949.198.camel@mojatatu>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322141102.1949.198.camel@mojatatu>
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

On Nov 24, 2011, at 5:25 AM, jamal wrote:

> The most basic IMO is to use netlink if you are doing
> it from a programmatic interface. You seem to be doing that
> already for other items (eg HTB) in the setup. There are
> a few libraries out there you could use but i realize
> that they may not match your license requirements.
> Maybe you could isolate your netlink code and make it 
> standalone based on the license you use and people who 
> need that could use it.

You're right--calling tc directly through system() is kind of ugly.  That code was written a *long* time ago when we wanted a quick QoS story.  As you mentioned, we use netlink to configure traffic shaping, so we have all the pieces at this point.  I just think no one ever bothered to clean up that little wart in userspace.  I'll put that on my to-do list.  Obviously, this doesn't affect the kernel portions.  Thanks for bringing it to our attention.

> The other thing, is you match every flow on the specific
> virtual port - this may be design intent but it appears
> very inflexible.

We encourage users to use shaping, since it generally provides better results (and we do expose per-flow granularity there).  As a result, we haven't seen a need to improve support for policing.

--Justin
