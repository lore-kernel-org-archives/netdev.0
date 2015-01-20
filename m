From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Tue, 20 Jan 2015 15:05:17 +0100
Message-ID: <1702448.pOVnDx4KzI@wuerfel>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org> <2318041.V2OJAPu7gC@wuerfel> <3ad19b16fe5c58612479f70c052d0045.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: jcliburn@gmail.com, grant.likely@linaro.org, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: wstephen@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:65004 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbbATOF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:05:29 -0500
In-Reply-To: <3ad19b16fe5c58612479f70c052d0045.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 January 2015 21:58:09 wstephen@codeaurora.org wrote:
> > On Thursday 15 January 2015 08:12:51 wstephen@codeaurora.org wrote:
> >
> >> The nss-gmac driver is designed to work standalone or with the nss-drv
> >> driver so the switchable data plane overlay was implemented. When it
> >> worked standalone, the data plane is running on the ARM core as a
> >> standard
> >> networking driver.
> >
> > How do you decide which way it gets used on a particular system?
> >
> 
> By default the GMAC driver uses a native (Host ARM CPU) based data plane. 
> If the configuration loads the offload nss-drv driver, the offload driver
> registers an overlay with the GMAC.

Right. For review purposes, I think it would be helpful to split this
huge patch into several steps then:

- add a base driver
- add the overlay interface
- add the nss driver

Ideally more of them.

> >> The nss-drv driver can take over the data plane and
> >> offload it to the NSS cores. The STMicro stmmac driver does not have
> >> this
> >> kind of overlay design so is not suitable for IPQ806x. This is why we
> >> don't based on the stmmac driver
> >
> > Which kind of offload is implemented specifically? 'data plane' sounds
> > fairly generic and could mean anything, and the code isn't readable enough
> > in its current form for me to find out.
> 
> The Network Subsystem (NSS core) provides a GMAC pass-through until it is
> given a rule to offload work.  Once a rule is given, it is capable of
> performing: bridging, IPv4 NAT/FWD, IPv6 NAT/FWD, IPSec, LAG, and other
> protocols.
> 
> Hope this clarify your question!

Thanks for the description, this sounds very interesting indeed. I do
have more questions though: how do you get the rules into the NSS driver?
Does this get handled transparently by the openvswitch driver or
did you have to add new user interfaces for it?

	Arnd
