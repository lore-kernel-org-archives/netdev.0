From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sat, 10 Mar 2012 12:06:19 -0500
Message-ID: <20120310170619.GC22880@kvack.org>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com> <20120304170101.GH21526@kvack.org> <CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com> <20120308161138.GB23774@kvack.org> <CAKLmikPtvOLgzuSTF=vwfZcMD7jWWRSgWaLxnSxBsa=2RSnPVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Mitar <mmitar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56254 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab2CJRGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 12:06:20 -0500
Content-Disposition: inline
In-Reply-To: <CAKLmikPtvOLgzuSTF=vwfZcMD7jWWRSgWaLxnSxBsa=2RSnPVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 10, 2012 at 08:31:28AM -0800, Mitar wrote:
> Hi!
> 
> On Thu, Mar 8, 2012 at 8:11 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> > On Tue, Mar 06, 2012 at 12:58:44AM +0100, Mitar wrote:
> >> I would like something state-less. I see L2TPv3 has support for
> >
> > How stateless?
> 
> Stateless in the ethernet-like manner: each incoming packet is simply
> decapsulated and seen as it came over the (virtual) ethernet wire.

To be honest, I don't see any new stateless protocol actually being widely 
supported.  Building a completely proprietary solution (regardless of it 
being open source or not) that isn't supported by any common hardware or 
software networking platforms will paint yourself into a corner when it 
comes time to upgrade the network with additional capacity.

> Of course this is because I have one implementation of our needs in my
> head. Probably stateless is not necessary if everything is done
> automatically. But what I am saying is that it could be even
> stateless, something very very simple (and efficient). That we do not
> need state/sessions (on a tunnel level, of course on the IP level of
> packets send around then network kernel can (and should) keep state).
> Not much CPU computation, not much memory copying, no user-space
> context switching.

MPLS falls under that category, but it isn't commonly used in a completely 
stateless fashion either.  Bridging is relatively inexpensive, and GVRP is 
commonly used to dynamically configure VLANs in aggregation networks.  It 
has the advantage of being well supported by managed switches.  L2TP tunnel 
switching is a low cost operation (change tunnel/session id and ip 
addresses in the header), and, again, is well supported.

If you're using Linux as a router, I'd probably lean towards a VLAN based 
protocol, as anything exotic won't be supported by common nic's hardware 
checksum offloading.  L2TP can at least be carried in UDP packets which 
will can have their checksum calculation offloaded.  I don't think MPLS 
headers are recognized by any commodity NICs.

> The idea is that we need a very simple solution, robust, no
> encryption, no authentication. Just to improve the throughput on
> consumer routers (today with N protocol you can easily have 15Mbit/s+
> links and with fiber to tunnel them further this means that CPU is
> often a bottleneck).

Stateless != robust.  To deal with failed links you need some sort of state 
that is maintained by the system to switch over to backup links.

> As I see there is no simple (both in implementation and configuration
> manner) solution to this problem yet? Would it be then interesting to
> develop such kernel module as I described in my initial post? Is there
> any chance of it being accepted into the kernel?

Again, I don't see the point, as Yet Another Tunneling Protocol is a mess 
of support work for no real gain.  Existing options (MPLS, GVRP, L2TP) can 
all be configured with a minimum amount of state, are widely used for the 
scenario you're describing, and have migration paths when you need to 
upgrade to higher capacity switches/routers.

		-ben
-- 
"Thought is the essence of where you are now."
