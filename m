From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Tue, 22 Nov 2011 22:07:24 -0500
Message-ID: <1322017644.2039.57.camel@mojatatu>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<1321878007.2291.12.camel@mojatatu>
	<CAEP_g=8puZh8hihoyoHTc4f6cBu4jiDJQ6tqk6suQxR=dchyjA@mail.gmail.com>
	<1322012755.2039.36.camel@mojatatu>  <4ECC5AAB.8000605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <4ECC5AAB.8000605-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Tue, 2011-11-22 at 18:30 -0800, John Fastabend wrote:

> He is pushing and popping entire tags off 802.1Q for now but
> you can easily imagine MPLS tags and all sorts of other things
> people will _need_.

Lots of packet munging already happening with actions. 
We can pedit/nat/iptables/checksum/etc/. Works very well.

> Do we want tc and likely the skbedit action to explode into a
> packet mangling tool? 

skbedit is the wrong action to use. I would write one with
a cutnpaste of the code they have to do vlan manipulation.

> Would it make sense to plug into ebtables
> perhaps with a new family, NFPROTO_OPENFLOW or even on the
> existing NFPROTO_BRIDGE.

There is _nothing_ that openflow needs that cant be done
in classifier-action piece.
A good number of the actions they need exist already. 

> Although doing it with classifiers and more actions would flush
> out that TODO in act_mirred, and get us an mq_ingress among
> other things.

The packet redirect to user space is achieveable in many other
ways, thats why it was not added.

cheers,
jamal
