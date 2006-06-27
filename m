From: Dan Faerch <dan@scannet.dk>
Subject: Re: [patch 2/3] drivers/net/ns83820.c: add paramter to disable
	autonegotiation
Date: Tue, 27 Jun 2006 13:43:28 +0200
Message-ID: <1151408608.20631.28.camel@dan>
References: <200606250844.k5P8iasE020794@shell0.pdx.osdl.net>
	 <20060626162928.GA22614@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	dan@hacker.dk, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.exserver.dk ([195.69.129.177]:23208 "EHLO
	exsmtp01.exserver.dk") by vger.kernel.org with ESMTP
	id S932168AbWF0LmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 07:42:21 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060626162928.GA22614@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-26 at 12:29 -0400, Benjamin LaHaise wrote:
> This part is good, although doing something for copper cards needs doing, 
> which probably means poking around to support the phy properly.
I Agree. But i dont have a copper card, nor the knowledge to do this. I
was actually hoping that someone could "fill in the blanks".

> > Also added a "disable_autoneg" module argument to completely disable
> > autoneg on all cards using this driver.
> 
> This is the part I disagree with.  Are you sure it isn't a bug in the 
> link autonegotiation state machine for fibre cards?  It should be defaulting 
> to 1Gbit/full duplex if no autonegotiation is happening, and if it isn't 
> then that should be fixed instead of papering over things with a config 
> option.
In my setup, we use several fibercards on passive fiber-taps (tx only),
thus there is no link partner. If i dont disable autoneg, i simply cant
sniff traffic.
Skipping the initial autoneg solved the problem. Adding ethtool support
was just an extra courtesy upon request.
After adding ethtool support, i kept the disable_autoneg option to allow
one to operate with default autoneg disabled, and enabling autoneg
through ethtool where needed. Sort of a "reverse operation" mode.

If there IS a bug in the autoneg statemachine i would have no idea how
to fix it. My knowledge of hardware & drivers is unfortunately extremely
limited.

- Dan


