From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 00/24] Support MDIO devices
Date: Mon, 04 Jan 2016 18:21:47 -0800
Message-ID: <568B28BB.60804@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36792 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbcAECWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:22:18 -0500
Received: by mail-pf0-f178.google.com with SMTP id 65so166593211pff.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:22:18 -0800 (PST)
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 04/01/16 09:36, Andrew Lunn wrote:
> The discussions about changing the way DSA probes switches resulted in
> the wish to have switches attached to an MDIO bus to be represented as
> an MDIO device. However the current code only supports PHYs on MDIO
> busses. This patchset remedies this problem. It consists of a number
> of cleanups, abstraction for accessing structure members, and
> refactoring, as well as adding the concept of a generic MDIO device
> and MDIO driver. The last two patches then make use of this facility
> with a simple test driver, which will be discarded once we are past
> RFC stage.
> 

Happy new year! Thanks a lot for getting this out both quickly and in an
excellent shape and quality.

Here are few questions that come to mind with the new MDIO device model:

- what kind of API do we need to offer to Ethernet MAC driver? Would
attach/detach and maybe adjust_link be good enough?

- should we consider modeling a MDIO connected switch as a MDIO device
(responding at the pseudo PHY address on the MDIO bus) which then
eventually creates a child MDIO bus and per-port individual PHY devices?

- for MDIO switches with a data-path to an Ethernet MAC (which is
probably 99% of the cases, are there some which do not have such a thing
and are still managed switches?), how much of the existing PHY device
properties (speed, duplex, interface, pause capability) should we think
about moving to the common MDIO device structure? Then this kind of
circles back to the first question about the Ethernet MAC interface API [1]

[1]: One could imagine that the MDIO device with a data-path to an
Ethernet MAC would need at least (RGS)MII knowledge, speed, duplex, and
pause capability, all of that could come from a fixed-link (or similar)
property in DT/platform_data, or as a last resort, the MDIO device
driver, after successful probing could define these parameters.

The Ethernet MAC attaching to that MDIO device would need to be fed with
that information somehow such that we do not have to put too much
knowledge into the MAC driver and still preserve a good layering. Using
something similar to phy_{attach,connect}() (without starting a state
machine here) and phy_{detach,disconnect}() as well as an adjust_link
callback could help minimize the churn on the Ethernet driver side.
Would that seem sensible?

Thanks!
-- 
Florian
