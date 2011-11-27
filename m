From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Sun, 27 Nov 2011 16:31:45 -0500
Message-ID: <1322429505.7338.56.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322035942.1298.56.camel@edumazet-laptop>
	<1322052463.2039.135.camel@mojatatu>
	<1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1322055858.2039.188.camel@mojatatu> <4ECD19AC.8090505@intel.com>
	<1322140779.1949.191.camel@mojatatu>
	<20111127193438.GV795@wantstofly.org>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111127193438.GV795-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
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

On Sun, 2011-11-27 at 20:34 +0100, Lennert Buytenhek wrote:
> On Thu, Nov 24, 2011 at 08:19:39AM -0500, Jamal Hadi Salim wrote:


> There's a bunch of features that the hardware supports that have no
> analog in the Linux networking stack (e.g. port mirroring a non-CPU
> port to another non-CPU port),

You can mirror on Linux; eg to intercept packets on dev XXX
and mirror on eth0:

tc filter add dev XXX parent ffff: prio Y .. match blah \
action mirred egress mirror dev eth0

a more fun one to mirror to two ports:
tc filter add dev XXX parent ffff: prio Y .. match blah \
action mirred egress mirror dev eth0 \
action mirred egress mirror dev eth1

or even more fun, to mirror to two then do a total redirect:
tc filter add dev XXX parent ffff: prio Y .. match blah \
action mirred egress mirror dev eth0 \
action mirred egress mirror dev eth1 \
action mirred egress redirect dev eth2

Of course you can thrown in other actions in between those
to edit packets etc before redirecting.

cheers,
jamal
