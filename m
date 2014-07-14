From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only
 require the I bit to be set
Date: Mon, 14 Jul 2014 09:18:02 +0100
Message-ID: <20140714081802.GA19186@casper.infradead.org>
References: <cover.1405097440.git.tgraf@suug.ch>
 <cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
 <CA+mtBx_VpbrddO3AMRZbZ3Qdkp2QBs5i7rN2tqD4GFM0hT7zYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	nicolas.dichtel@6wind.com, Pravin B Shelar <pshelar@nicira.com>,
	xiyou.wangcong@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50616 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbaGNISH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 04:18:07 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx_VpbrddO3AMRZbZ3Qdkp2QBs5i7rN2tqD4GFM0hT7zYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/14 at 03:08pm, Tom Herbert wrote:
> On Fri, Jul 11, 2014 at 9:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > The VXLAN receive code is currently conservative in what it accepts and
> > will reject any frame that uses any of the reserved fields. The VXLAN
> > draft specifies that "reserved fields MUST be set to zero on transmit
> > and ignored on receive." though.
> >
> > Be liberal in only requiring the I bit to allow for VXLAN extensions
> > to be implemented.
> >
> This is not robust (this is a problem in the VXLAN spec not your
> patch). There is no requirement that the VXLAN bits are optional. For
> example, if a receiver accepts a GPE packet but doesn't implement it
> the packet will be misinterpreted. I've already pointed this out to
> the VLXAN folks on nvo3 list. Dropping packets with unknown bits set
> is the only sane approach.

I agree, it's a mess.

At least VXLAN-gpe has realized this and will reserve an individual
port number. The port number is not yet fixed so it can't be enforced
yet but once that is done, gpe frame acceptance can be bound to the use
of that particular UDP port.
