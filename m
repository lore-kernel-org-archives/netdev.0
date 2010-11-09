From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 09:49:41 -0500
Message-ID: <20101109144941.GA4018@canuck.infradead.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
 <4CD6DF37.6010800@trash.net>
 <20101108151635.GA20629@canuck.infradead.org>
 <4CD91406.4000603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:48124 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab0KIOtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 09:49:46 -0500
Content-Disposition: inline
In-Reply-To: <4CD91406.4000603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 10:27:34AM +0100, Patrick McHardy wrote:
> Am 08.11.2010 16:16, schrieb Thomas Graf:
> > On Sun, Nov 07, 2010 at 06:17:43PM +0100, Patrick McHardy wrote:
> >> On 07.11.2010 17:44, Jan Engelhardt wrote:
> >>> ...
> > 
> >> That's somewhat similar to the nlattr32 idea, but a length of 0 makes
> >> more sense since that's currently not used. In that case the length
> >> would be read from a second length field which has 32 bits.
> > 
> > I agree. This makes perfect sense. I was just thinking wheter we want
> > to encode more information into the attribute header if we extend it
> > anyways.
> 
> What kind of additional information are you thinking about?

We have tried to come up with ways of forwarding netlink messages to
other machines several times. It always failed due to the fact that
protocols encode attributes/data differently without having the
ability to specify the encoding. E.g. we have nfnetlink encoding
everything in network byte order, most others encode it in host byte
order. Therefore all parsers must be aware of all protocols if they
want to forward/do something with the data. A flag would help there.

I haven't given up on the idea of self describing netlink protocols
yet. For example we could encode the attribute type
(i8|u16|u32|u16|string) in additional to the existing nested attribute
flag.

Given this additional meta data to each attribute and given we limit
ourselves to only using strict netlink attribtes going forward, i.e.
we no longer encode whole structs in attributes we'd be given netlink
protocols which can be forwarded, saved, audited while still being
fairly efficient.
