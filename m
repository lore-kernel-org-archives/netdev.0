From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 21:20:09 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org> <4CD91406.4000603@trash.net> <20101109144941.GA4018@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:60716 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129Ab0KIUUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 15:20:11 -0500
In-Reply-To: <20101109144941.GA4018@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2010-11-09 15:49, Thomas Graf wrote:
>
>We have tried to come up with ways of forwarding netlink messages to
>other machines several times. It always failed due to the fact that
>protocols encode attributes/data differently without having the
>ability to specify the encoding.

What's more, there is no way to specify a remote host in sockaddr_nl
right now, so all communication is necessarily being local - that is,
unless you add a hidden forwarder in kernel space that transparently
tunnels it into IPv6 or something.

>I haven't given up on the idea of self describing netlink protocols
>yet. For example we could encode the attribute type
>(i8|u16|u32|u16|string) in additional to the existing nested attribute
>flag.

I do not believe that encoding the attribute type into the protocol
itself is going to be such a big win. You still need a local
authoritative database (struct nla_policy[] or some representation of
it, nevermind I'm thinking "XML-DTD"-like) to do the verification
against because some NL messages may be purposely forged. If you have
an nlattr that says it is a string, how do you know that it is in
fact a string rather than a blob that happens to have a trailing \0.
