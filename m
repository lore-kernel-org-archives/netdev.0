From: Bill Fink <billfink@mindspring.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw
 MAC address
Date: Wed, 12 Feb 2014 12:17:39 -0500
Message-ID: <20140212121739.ecb2f222.billfink@mindspring.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
	<1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
	<1392108205.22033.16.camel@dagon.hellion.org.uk>
	<CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
	<1392203708.13563.50.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392203708.13563.50.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Feb 2014, Ian Campbell wrote:

> On Tue, 2014-02-11 at 13:53 -0800, Luis R. Rodriguez wrote:
> > Cc'ing kvm folks as they may have a shared interest on the shared
> > physical case with the bridge (non NAT).
> > 
> > On Tue, Feb 11, 2014 at 12:43 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > > On Mon, 2014-02-10 at 14:29 -0800, Luis R. Rodriguez wrote:
> > >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > >>
> > >> Although the xen-netback interfaces do not participate in the
> > >> link as a typical Ethernet device interfaces for them are
> > >> still required under the current archtitecture. IPv6 addresses
> > >> do not need to be created or assigned on the xen-netback interfaces
> > >> however, even if the frontend devices do need them, so clear the
> > >> multicast flag to ensure the net core does not initiate IPv6
> > >> Stateless Address Autoconfiguration.
> > >
> > > How does disabling SAA flow from the absence of multicast?
> > 
> > See patch 1 in this series [0], but I explain the issue I see with
> > this on the cover letter [1].
> 
> Oop, I felt like I'd missed some context. Thanks for pointing out that
> it was right under my nose.
> 
> > In summary the RFCs on IPv6 make it
> > clear you need multicast for Stateless address autoconfiguration
> > (SLAAC is the preferred acronym) and DAD,
> 
> That seems reasonable, but I think is the opposite to what I was trying
> to get at.
> 
> Why is it not possible to disable SLAAC and/or DAD even if multicast is
> present?
> 
> IOW -- enabling/disabling multicast seems to me to be an odd proxy for
> disabling SLAAC or DAD and AIUI your patch fixes the opposite case,
> which is to avoid SLAAC and DAD on interfaces which don't do multicast
> (which makes sense since those protocols involve multicast).

Forgive me if this doesn't make sense in this context since
I'm not a kernel developer, but I was just wondering if any of
the sysctls:

	/proc/sys/net/ipv6/conf/<ifc>/disable_ipv6
	/proc/sys/net/ipv6/conf/<ifc>/accept_dad
	/proc/sys/net/ipv6/conf/<ifc>/accept_ra
	/proc/sys/net/ipv6/conf/<ifc>/autoconf

would be apropos for the requirement being discussed.

					-Bill
