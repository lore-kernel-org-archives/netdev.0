From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 18:54:37 -0500
Message-ID: <20101109235437.GE11005@canuck.infradead.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
 <4CD6DF37.6010800@trash.net>
 <20101108151635.GA20629@canuck.infradead.org>
 <4CD91406.4000603@trash.net>
 <20101109144941.GA4018@canuck.infradead.org>
 <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
 <20101109214039.GA11005@canuck.infradead.org>
 <alpine.LNX.2.01.1011092302070.28314@obet.zrqbmnf.qr>
 <20101109233550.GD11005@canuck.infradead.org>
 <alpine.LNX.2.01.1011100040220.7998@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:33460 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab0KIXyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 18:54:41 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1011100040220.7998@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 10, 2010 at 12:42:25AM +0100, Jan Engelhardt wrote:
> On Wednesday 2010-11-10 00:35, Thomas Graf wrote:
> >On Tue, Nov 09, 2010 at 11:02:30PM +0100, Jan Engelhardt wrote:
> >> And while we're discussing this, surely there are no objections
> >> to bumping NLA_ALIGN to 8 at the same time..
> >
> >We can't do that. That would break _everything_.
> 
> Using nlattr_ext also breaks _something_, unless it's only used for new 
> stuff. Similarly, a new NLA_EXT_ALIGN could be used with just those that 
> also start using nlattr_ext.

If you want to change alignment for new protocols that's fine but you won't
be able to use the existing attribute API on either side.

nlattr_ext2 or nlattr32 could be used in existing protocols if we used a special
attribute type (f.e. 0xffff) instead of nla_len == 0 to identify them and as long
as the attribute size does not exceed 64K as obviously no older parser would be
able to skip over such attributes correctly.

So yes, large attributes would only be permitted in new protocols which are
guaranteed to have a capable parser but we would at least not have to duplicate
the API but just slightly extend it.
