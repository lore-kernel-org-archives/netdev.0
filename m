From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/13] bnx2x: Forbid LRO on when XEN is enabled
Date: Sun, 18 Apr 2010 20:58:58 -0700 (PDT)
Message-ID: <20100418.205858.193699902.davem@davemloft.net>
References: <1271602258.27235.200.camel@lb-tlvb-vladz>
	<1271603485.3679.210.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org,
	dmitry@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753846Ab0DSD6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 23:58:53 -0400
In-Reply-To: <1271603485.3679.210.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 18 Apr 2010 16:11:25 +0100

> On Sun, 2010-04-18 at 17:50 +0300, Vladislav Zolotarov wrote:
>> LRO cannot be used on virtualized environment, so it is best
>> to disable it on compile time in XEN kernel.
> [...]
> 
> If you want to cripple your performance, I'm not going to stand in your
> way, but be aware that most distribution kernels now enable CONFIG_XEN.

There is also zero reason to do this.

When the XEN code or whatever setups up the bridge, LRO will be
disabled by the bridge code.

It automatically issues ethtool LRO disable commands to the devices
involved in the bridge configuration.  And it has done this for
a _long_ time.  The ipv4 routing code will do the same.

This change is bogus and likely based upon behavior in some ancient
distribution kernel that lacks the ethtool facilities.

I absolutely refuse to apply this.
