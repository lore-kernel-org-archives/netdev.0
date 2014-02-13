From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC address
Date: Wed, 12 Feb 2014 20:27:52 -0800
Message-ID: <CAB=NE6Vf4KHyMGiGZuuvZ8uWhw51UXbhHPt5RxqZaJbLHOU71w@mail.gmail.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
 <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
 <1392108205.22033.16.camel@dagon.hellion.org.uk> <CAB=NE6Vu=khpj_3J7r-u8DFkhyC-RgLikNFtOU-WO7te_4HMCw@mail.gmail.com>
 <1392203708.13563.50.camel@kazak.uk.xensource.com> <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6WFDWW1faoCYJP9zh6rPPvET+dbHxjHnGkYXtRx6z2LOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 2:05 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> We have to be careful for sure, I'll try to test all cases including
> kvm, but architecturally as I see it so far these things are simply
> exchanging over data through their respective backend channels, I know
> ipv6 interfaces are unused and I'm going to dig further to see why at
> least one ipv4 interfaces is needed. I cannot fathom why either of
> these interfaces would be required. I'll do a bit more digging.
>
> The TAP interface requirements may be different, I haven't yet dug into that.

I have a test patch that now works that restricts xen-netback from
getting any IPv4 and IPv6 addresses, and disables multicast. With this
set in place the xen-frontend still gets IPv4 and IPv6 addresses and
Multicast still works. This was tested under a shared physical
environment, I'll have to test NAT next, and also see if we can enable
this as an option for KVM for their TAP 'backend' interfaces.

  Luis
