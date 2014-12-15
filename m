From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Mon, 15 Dec 2014 09:56:38 +0100
Message-ID: <20141215085637.GL16916@distanz.ch>
References: <20141212162746.GJ16916@distanz.ch>
 <20141212.113020.884577050283133272.davem@davemloft.net>
 <20141212164528.GK16916@distanz.ch>
 <20141212.115838.1155760587618419145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony@atomide.com, nico@fluxnic.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:56735 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbaLOI4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 03:56:41 -0500
Content-Disposition: inline
In-Reply-To: <20141212.115838.1155760587618419145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 17:58:38 +0100, David Miller <davem@davemloft.net> wrote:
> From: Tobias Klauser <tklauser@distanz.ch>
> Date: Fri, 12 Dec 2014 17:45:29 +0100
> 
> > On 2014-12-12 at 17:30:20 +0100, David Miller <davem@davemloft.net> wrote:
> >> In my opinion, if the code blocks enabling the configurations that
> >> need this are enabled, so should GPIO be depended upon.
> >> 
> >> I think, at a minimum, when CONFIG_OF is enabled smsc91x should
> >> require GPIO.
> > 
> > Agreed. This is the better solution, causing less surprises for the
> > user. Should this be a "select GPIOLIB if OF" then?
> 
> If GPIO is a child node in the Kconfig hierarchy (ie. has no
> dependencies of it's own), then yes.  Otherwise, a depends
> will need to be used, because select does not recursively
> trigger a select'd nodes dependencies.

Thank you for the explanation. Since GPIOLIB depends on
ARCH_WANT_OPTIONAL_GPIOLIB || ARCH_REQUIRE_GPIOLIB, I think it's
appropriate to let SMC91X depend on (!OF || GPIOLIB). I'll send an
updated patch.
