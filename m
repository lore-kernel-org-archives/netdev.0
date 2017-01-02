From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] Documentation: devicetree: Add bindings info for
 rfkill-regulator
Date: Mon, 02 Jan 2017 15:57:07 +0100
Message-ID: <1483369027.21014.11.camel@sipsolutions.net>
References: <20161101105840.24313-1-paul@crapouillou.net>
         <20161109182612.i4rnsdxulk5ghemz@rob-hp-laptop>
         (sfid-20161109_192614_527668_B4DB10FA)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Maarten ter Huurne <maarten@treewalker.org>
To: Rob Herring <robh@kernel.org>, Paul Cercueil <paul@crapouillou.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40274 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755833AbdABO5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Jan 2017 09:57:16 -0500
In-Reply-To: <20161109182612.i4rnsdxulk5ghemz@rob-hp-laptop> (sfid-20161109_192614_527668_B4DB10FA)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> My understanding is it is generally felt that using the regulator
> enable GPIO commonly found on WiFi chips for rfkill is an abuse of
> rfkill as it is more that just an RF disable. From a DT standpoint,
> this seems like creating a binding for what a Linux driver wants.
> Instead, I think this should be either a GPIO or GPIO regulator and
> the driver for the WiFi chip should decide whether or not to register
> that as an rfkill driver.

Sadly, there are two ways to use rfkill right now:

1) the more common, and correct, way of having rfkill be a control tied
to a specific wireless interface (wifi, BT, FM, GPS, NFC, ...), to both
report the hardware button state that might be tied to it, and to
control - centrally - the software state.

2) the platform way, which some ACPI based platforms do, which register
an rfkill instance, which often allows controlling in software the
hardware line that then toggles the hardware rfkill on the WiFi NIC.


It's not clear to me what this patch is trying to achieve. It seems a
bit like something else entirely, which would be using it to toggle the
power for a wifi device? I agree that doesn't seem appropriate, and
instead the driver could bind to the regulator and disable it when wifi
gets disabled (by rfkill or simply by taking all interfaces down.)


In fact, given that there are no in-tree users, I'm tempted to remove
the rfkill-regulator entirely. Thoughts?

johannes
