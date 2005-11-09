From: Hasso Tepper <hasso@estpak.ee>
Subject: [quagga-dev 3824] Re: Patch: RFC2863 #1 (incomplete)
Date: Wed, 9 Nov 2005 11:00:32 +0200
Message-ID: <200511091100.33154.hasso@estpak.ee>
References: <200511070042.28572.stefan@loplof.de>
	<200511081714.30261.hasso@estpak.ee>
	<20051109001921.GK23537@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, quagga-dev@lists.quagga.net,
   Stefan Rompf <stefan@loplof.de>
Return-path: <quagga-dev-bounces@lists.quagga.net>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20051109001921.GK23537@postel.suug.ch>
Content-Disposition: inline
List-Unsubscribe: <http://lists.quagga.net/mailman/listinfo/quagga-dev>,
	<mailto:quagga-dev-request@lists.quagga.net?subject=unsubscribe>
List-Archive: <http://lists.quagga.net/pipermail/quagga-dev>
List-Post: <mailto:quagga-dev@lists.quagga.net>
List-Help: <mailto:quagga-dev-request@lists.quagga.net?subject=help>
List-Subscribe: <http://lists.quagga.net/mailman/listinfo/quagga-dev>,
	<mailto:quagga-dev-request@lists.quagga.net?subject=subscribe>
Sender: quagga-dev-bounces@lists.quagga.net
Errors-To: quagga-dev-bounces@lists.quagga.net
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> OK, my point might not be the best, still I think it is valid. The fact
> that certain routes have to be excluded from the routing calculation
> even if their link is up and running makes it obvious that the routing
> daemon can take care of DORMANT_L3DOWN itself and we don't need the
> kernel to hide them. Nothing more.

No. Routing daemon deals only with info from neighbours. While you can
say that "if link is down => neighbour is unreachable", you can't say
absolutely nothing about link if neighbour is down. Even with PtP media.
If neighbour is down, it just means that neighbour is down, but best
route to the neighbour is still via this link.
 
> We're talking about the auto routes in the main table, right? There
> is no reason for the addresses to be configured as a prefix, they
> can, and in my opinion should, be added as /~0 if the net is not
> guaranteed to be reachable at exactly this interface at all times.
> e.g. a user adding the address 1.1.1.1/24 on eth3 clearly says that
> 1.1.1.0/24 is always behind eth3, no matter what.

Really? How it can be behind eth3 if state of eth3 says that "no packets
to this link - it's DOWN"?
 
> If the route is supposed to be non-static then the address should be
> added as /32 to avoid the auto route in main table and the broadcast
> routes in the local table. Instead the routing daemon should be
> responsible of manging 1.1.1.0/24 at all times.
>
> Does this make sense?

No. This mandates usage of routing daemon even in my laptop which is
nonsense.
 
> Now even if this is not acceptable and you really need a way to
> favour routes added by userspace over auto/connected routes then
> we should fix this in the routing itself and not with a new
> opertional state interface state.

I'm not talking about new operational state of interface. I'm talking
about simple rule - if link is known to be unusable (!IFF_RUNNING), don't
use routes pointed to this link. Whether they are connected routes
created by kernel or static routes created by user.

Simple scenario with my personal laptop - wired ethernet
(192.168.1.10/24) and wireless (172.16.100.10/24). Two defaults, wireless
one is with higher metric. If I walk away from my table and disconnect
wired ethernet cable, I'd expect that it wouldn't use default pointed to
wired network _and_ 192.168.1.0/24 pointed to it any more. Default
pointed to the wireless is there, wireless link is known to be usable
(IFF_RUNNING) and 192.168.1.0/24 is reachable via wireless as well.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
