From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Mon, 28 Nov 2011 08:01:17 -0800
Message-ID: <20111128160117.GA6349@nicira.com>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<1322488954.7338.66.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1322488954.7338.66.camel@mojatatu>
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

On Mon, Nov 28, 2011 at 09:02:34AM -0500, Jamal Hadi Salim wrote:
> On Mon, 2011-11-28 at 21:04 +0800, Herbert Xu wrote:
> > However, what's more worrying for me right now is the gaping
> > DoS opportunities that exist in the patch as is.
> > 
> > In particular, the whole design principle of punting all new
> > flows to user-space is an excellent way of attacking the system.
> 
> Indeed this is an issue with openflow in general.
> The general solution is to rate limit how much goes to the controller
> but even that is insufficient.

Regarding OpenFlow rate limiting, in addition to Martin's response, Open
vSwitch has implemented controller rate limiting since day one.  It is
documented in ovs-vswitchd.conf.db(5):

     OpenFlow Rate Limiting:

       controller_rate_limit: optional integer, at least 100
              The maximum rate at which packets in unknown flows will be  for-
              warded  to the OpenFlow controller, in packets per second.  This
              feature prevents a single  bridge  from  overwhelming  the  con-
              troller.   If  not specified, the default is implementation-spe-
              cific.

              In addition, when  a  high  rate  triggers  rate-limiting,  Open
              vSwitch  queues  controller  packets for each port and transmits
              them to the controller at the configured rate.   The  number  of
              queued  packets  is limited by the controller_burst_limit value.
              The packet queue is shared fairly among the ports on a bridge.

              Open vSwitch maintains two such packet rate-limiters per bridge.
              One  of  these  applies  to  packets  sent  up to the controller
              because they do not correspond to any flow.  The  other  applies
              to  packets  sent  up  to the controller by request through flow
              actions. When both rate-limiters are filled  with  packets,  the
              actual  rate  that  packets  are sent to the controller is up to
              twice the specified rate.

       controller_burst_limit: optional integer, at least 25
              In conjunction with controller_rate_limit, the maximum number of
              unused  packet credits that the bridge will allow to accumulate,
              in packets.  If not specified, the  default  is  implementation-
              specific.
