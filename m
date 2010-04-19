From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 11/13] bnx2x: Forbid LRO on when XEN is enabled
Date: Mon, 19 Apr 2010 09:14:46 -0700
Message-ID: <20100419091446.39e2510c@nehalam>
References: <1271602258.27235.200.camel@lb-tlvb-vladz>
	<1271603485.3679.210.camel@localhost>
	<20100418.205858.193699902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, vladz@broadcom.com, eilong@broadcom.com,
	netdev@vger.kernel.org, dmitry@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34224 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab0DSUOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 16:14:32 -0400
In-Reply-To: <20100418.205858.193699902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Apr 2010 20:58:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sun, 18 Apr 2010 16:11:25 +0100
> 
> > On Sun, 2010-04-18 at 17:50 +0300, Vladislav Zolotarov wrote:
> >> LRO cannot be used on virtualized environment, so it is best
> >> to disable it on compile time in XEN kernel.
> > [...]
> > 
> > If you want to cripple your performance, I'm not going to stand in your
> > way, but be aware that most distribution kernels now enable CONFIG_XEN.
> 
> There is also zero reason to do this.
> 
> When the XEN code or whatever setups up the bridge, LRO will be
> disabled by the bridge code.
> 
> It automatically issues ethtool LRO disable commands to the devices
> involved in the bridge configuration.  And it has done this for
> a _long_ time.  The ipv4 routing code will do the same.
> 
> This change is bogus and likely based upon behavior in some ancient
> distribution kernel that lacks the ethtool facilities.
> 
> I absolutely refuse to apply this.

Agreed. It is often devices that implement LRO, but don't have way
to turn it off.
