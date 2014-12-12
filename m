From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 17:45:29 +0100
Message-ID: <20141212164528.GK16916@distanz.ch>
References: <20141212161100.GH2950@atomide.com>
 <20141212.112119.1395396406830853805.davem@davemloft.net>
 <20141212162746.GJ16916@distanz.ch>
 <20141212.113020.884577050283133272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony@atomide.com, nico@fluxnic.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:41120 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030233AbaLLQpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 11:45:32 -0500
Content-Disposition: inline
In-Reply-To: <20141212.113020.884577050283133272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-12-12 at 17:30:20 +0100, David Miller <davem@davemloft.net> wrote:
> From: Tobias Klauser <tklauser@distanz.ch>
> Date: Fri, 12 Dec 2014 17:27:46 +0100
> 
> > GPIO is not needed in all configurations of the chip, they are optional.
> > That's why I was going for the ugly #ifdef solution.
> > 
> > It seems that there are stubs for the functions in question in
> > linux/gpio/consumer.h already as Tony suggested. Thus, adding an
> > #include <linux/gpio/consumer.h> to the driver should be enough. I'll
> > send an updated patch.
> 
> So for the "configurations" that need it, how does the user figure out
> that GPIO is needed?

Probably ionly by consulting the manual of the board usingthe chip.
Which presumably very few users will do.

> In my opinion, if the code blocks enabling the configurations that
> need this are enabled, so should GPIO be depended upon.
> 
> I think, at a minimum, when CONFIG_OF is enabled smsc91x should
> require GPIO.

Agreed. This is the better solution, causing less surprises for the
user. Should this be a "select GPIOLIB if OF" then?
