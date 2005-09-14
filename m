From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 14 Sep 2005 21:09:04 +0200
Message-ID: <20050914190904.GB20273@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
	<431F5CD2.8020905@trash.net> <20050907215213.GB8222@schmorp.de>
	<432174EE.80306@trash.net> <20050911131943.GC9865@schmorp.de>
	<43243AB9.9000705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43243AB9.9000705@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 11, 2005 at 04:10:01PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> >>What network driver are you using?
> >
> >Happens with both skge and sk98.
> 
> Are you sure the same checksum error happens?

No, of course not.

I have two similar network cards in that machine (a normal sk98 pci card
and an onboard one that skge calls Yukon lite and the sk98lin driver calls
9521. The onboard one does not, though, work with sk98lin).

What I did test was with skge and the onboard card, and sk98_lin with
the pci card, and in both cases I couldn't get masquerading to work, but
everything else worked fine.

> ip_summed to CHECKSUM_HW, it uses either CHECKSUM_UNNECESSARY for
> HW checksummed packets, in which case the check is skipped in
> ip_conntrack, or it uses CHECKSUM_NONE, in which case the checksum
> in the packet must be invalid if the check fails and the packet
> wouldn't be accepted by the final receipient anyway. skge uses 
> CHECKSUM_HW for every packet, so they have nothing in common wrt.
> HW checksumming. This would normally mean we can rule out HW
> checksumming, but for some reason turning it off on skge seems
> to help in your case.

... and I have not tried turning it off with sk98lin (and would like to
avoid it, as it requires reconfiguration to test). If any additional tests
arre required, I will do them, though.

> >   nfs_acl                 3136  1 nfsd
> >   sunrpc                142632  13 nfsd,lockd,nfs_acl
> >
> >However, it happens with init=/bin/bash and loading the single iptables
> >rule I sent in the original report, for either eth0/1 or the ppp
> >interface. I can send you my 278 other rules if you want, but they have
> >had no effect on the problem here.
> 
> No, thanks. But your entire .config might help ..

Sorry for the delay :( It's here:

http://data.plan9.de/config.doom

This is the currently-running 2.6.13 config, when testing 2.6.11, i just
did "make oldconfig" on this one.

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
