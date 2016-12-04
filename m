From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management
 frames to CPU
Date: Sun, 4 Dec 2016 23:40:54 +0100
Message-ID: <20161204224054.GA24118@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
 <1480736720-12608-2-git-send-email-andrew@lunn.ch>
 <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
 <20161204202234.GA20743@lunn.ch>
 <87oa0r9wei.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39882 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751126AbcLDWk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 17:40:58 -0500
Content-Disposition: inline
In-Reply-To: <87oa0r9wei.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You can have several implementations in the same file (e.g. global1.c),
> so again the only value is the function name, not the struct member.

The structure member have g1_ has a lot of value.

        if (chip->info->ops->set_cpu_port) {
                err = chip->info->ops->set_cpu_port(chip, upstream_port);
                if (err)
                        return err;
        }

Where to i need to go look for set_cpu_port? I have no idea.

        if (chip->info->ops->g1_set_cpu_port) {
                err = chip->info->ops->g1_set_cpu_port(chip, upstream_port);
                if (err)
                        return err;
        }

Humm, the hint tells me it is in global1.c. And i also know that all
of them are in global1.c.

These ops do make the code simpler. But the downside is it makes it
harder to find the actual code, now that it is spread over multiple
files. And these hits help negate the downside a little.

   Andrew
