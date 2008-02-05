From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 22:20:52 +0100
Message-ID: <20080205212051.GN8953@1wt.eu>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205200211.GA26150@one.firstfloor.org> <20080205203911.GA9891@2ka.mipt.ru> <20080205212017.5db50114@core> <20080205215216.GB24275@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1744 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759941AbYBEWIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 17:08:10 -0500
Content-Disposition: inline
In-Reply-To: <20080205215216.GB24275@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 12:52:17AM +0300, Evgeniy Polyakov wrote:
> Hi Alan.
> 
> On Tue, Feb 05, 2008 at 09:20:17PM +0000, Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> > > Most (if not all) distributions have them enabled and window growing
> > > works just fine. Actually I do not see any reason why connection
> > > establishment handshake should prevent any run-time operations at all,
> > > even if it was setup during handshake.
> > 
> > Syncookies are only triggered if the system is under a load where it
> > would begin to lose connections otherwise. So they merely turn a DoS into
> > a working if slightly slower setup (and > 64K windows don't matter for
> > most normal users, especially on mobile devices).
> 
> SACK is actually a good idea for mobile devices, so preventing
> syncookies from not getting into account some options (btw, does it work
> with timestamps and PAWS?) is not a solution.

All TCP options negociated during session setup are lost. In fact, some
bits (3) are still reserved for the best known value of the MSS, but
that's all. The principle of SYN cookies is that the server does not
create any session upon the SYN, but builds a sequence number constitued
from a hash and the values it absolutely needs to know when the client
validates the session with an ACK.

I've seen some firewalls acting as SYN gateways which send the options
from the server to the client in the first ACK packet from the server.
This is normally not allowed, but it seems to work with some TCP stacks
(at least for the MSS). One solution would be to extend TCP to officially
support this behaviour and to optionally use it along with SYN cookies,
but there will always be old clients not compatible with the extension.

Regards,
Willy

