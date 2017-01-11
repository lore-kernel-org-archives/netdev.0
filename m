From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 10:00:18 -0800
Message-ID: <20170111180018.GC22289@roeck-us.net>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170111173741.GB13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:41332 "EHLO
        bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759916AbdAKSAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 13:00:21 -0500
Content-Disposition: inline
In-Reply-To: <20170111173741.GB13033@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 06:37:41PM +0100, Andrew Lunn wrote:
> 
> However, at the moment, there is no code to enable interrupts for
> temperature alarms. I also don't see any need to add such code, since
> there is nowhere in HWMON to actively report such an alarm condition.
> 
That is not entirely correct. It is not in the hwmon core, but that is
mostly because the sysfs attributes are managed in the hwmon drivers,
at least with the legacy API, and it is thus the responsibility of
hwmon drivers to implement interrupts and to alert user space.

It is on my task list to add a callback into the core, to support
generating udev and sysfs events with the new API, but so far I don't
see a need for it because no one requested it. This makes it kind
of a circular argument (not that the dsa hwmon driver supports the
new API anyway, but still).

Guenter
