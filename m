From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 22:02:44 +0000
Message-ID: <20141203220244.GA8822@casper.infradead.org>
References: <20141201135225.GA16814@casper.infradead.org>
 <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org>
 <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
 <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com>
 <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com>
 <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46070 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaLCWCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 17:02:48 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 at 11:38am, Jesse Gross wrote:
> On Wed, Dec 3, 2014 at 10:38 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > Both approaches seem strange. You are sending 1 packet an hour to
> > some destination behind 100 tunnels. Why would you want to
> > cut down your MTU for all packets? On the other hand,
> > doubling the amount of packets because your MTU is off
> > by a couple of bytes will hurt performance significantly.
> >
> > Still, if you want to cut down the MTU within guest,
> > that's only an ifconfig away.
> > Most people would not want to bother, I think it's a good
> > idea to make PMTU work properly for them.
> 
> I care about correctness first, which means that an Ethernet link
> being exposed to the guest should behave like Ethernet. So, yes, IPX
> should work if somebody chooses to do that.
> 
> Your comments are about performance optimization. That's fine but
> without a correct base to start from it seems like putting the cart
> before the horse and is hard to reason about.

I agree with Jesse in particular about correctnes but Michael has a
point (which I thing nobod objects to) which is that it may not always
make sense to force the MTU onto the guest. It clearly makes sense for
the edge server connected to an overlay but it may not be ideal if
WAN traffic is VXLAN encapped and local DC traffic is put onto a VLAN.

That said, I think it is fair to assume that the host knows what role
it plays and can be configured accordingly, i.e. a Netlink API which
exposes the encap overhead so libvirt can max() over it force it onto
the guest or something along those lines.
