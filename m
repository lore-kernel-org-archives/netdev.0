From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Netlink limitations
Date: Mon, 8 Nov 2010 10:16:35 -0500
Message-ID: <20101108151635.GA20629@canuck.infradead.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
 <4CD6DF37.6010800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:39573 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab0KHPQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 10:16:51 -0500
Content-Disposition: inline
In-Reply-To: <4CD6DF37.6010800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 07, 2010 at 06:17:43PM +0100, Patrick McHardy wrote:
> On 07.11.2010 17:44, Jan Engelhardt wrote:
> > we mentioned it only briefly at the Netfilter workshop a few weeks ago, 
> > but as I am trying to figure out how to use Netlink in Xtables, 
> > Netlink's limitations really start ruining my day.
> > 
> > The well-known issue is that NL messages the kernel is supposed to 
> > receive have a max size of 64K, due to nlmsghdr's use of uint16_t. This 
> > is very problematic because attributes can easily amass more than 64K. 
> > Think of a chain full of rules, represented by a top-level attribute 
> > that nests attributes. The problem is bidirectional, a table 
> > dump has the same problem.
> 
> Messages are not limited to 64k, individual attributes are. Holger
> started working on a nlattr32, which uses 32 bit for the length
> value.

Also, it is not required to pack everything in attributes. Your protocol
may specify that the whole message payload consists of chained attributes.
Alternatively you may as well split your attribut chain and dump them
as several messages.

If a large attribute container for nested attribtues is required, I agree
that nlattr32 is the way to go.

> That's somewhat similar to the nlattr32 idea, but a length of 0 makes
> more sense since that's currently not used. In that case the length
> would be read from a second length field which has 32 bits.

I agree. This makes perfect sense. I was just thinking wheter we want
to encode more information into the attribute header if we extend it
anyways.
