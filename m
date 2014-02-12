From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC
 address
Date: Wed, 12 Feb 2014 12:19:46 +0000
Message-ID: <20140212121946.GA31937@zion.uk.xensource.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
 <1392108205.22033.16.camel@dagon.hellion.org.uk>
 <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 11, 2014 at 01:53:26PM -0800, Luis R. Rodriguez wrote:
> Cc'ing kvm folks as they may have a shared interest on the shared
> physical case with the bridge (non NAT).
> 
> On Tue, Feb 11, 2014 at 12:43 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
> >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> >>
> >> Although the xen-netback interfaces do not participate in the
> >> link as a typical Ethernet device interfaces for them are
> >> still required under the current archtitecture. IPv6 addresses
> >> do not need to be created or assigned on the xen-netback interfaces
> >> however, even if the frontend devices do need them, so clear the
> >> multicast flag to ensure the net core does not initiate IPv6
> >> Stateless Address Autoconfiguration.
> >
> > How does disabling SAA flow from the absence of multicast?
> 
> See patch 1 in this series [0], but I explain the issue I see with
> this on the cover letter [1]. In summary the RFCs on IPv6 make it
> clear you need multicast for Stateless address autoconfiguration
> (SLAAC is the preferred acronym) and DAD, however the net core has not
> made this a requirement, and hence the patch. The caveat which I
> address on the cover letter needs to be seriously considered though.
> 
> [0] http://marc.info/?l=linux-netdev&m=139207142110535&w=2
> [1] http://marc.info/?l=linux-netdev&m=139207142110536&w=2
> 
> > Surely these should be controlled logically independently even if there is some
> > notional linkage.
> 
> When a node hops on a network it will query its network by sending a
> router solicitation multicast request for its configuration
> parameters, the router can respond with router advertisements to
> disable SLAAC.
> 
> Apart from that we have no other means to disable SLAAC neatly, and as
> I gather that would be counter to the IPv6 RFCs anyway, and that makes
> sense.
> 
> > Can SAA not be disabled directly?
> 
> Nope. The ipv6 core assumes all device want ipv6 and this is done upon
> netdev registration, and as I noted on my patch 1 description --
> although ipv6 supports a module parameter to disable autoconfiguration
> RFC4682 Section 5.4 makes it clear that DAD *MUST* be performed on all

FWIW: RFC4862 :-)

You had the same typo in patch 1.

Wei.
