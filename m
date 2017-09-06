From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 06 Sep 2017 10:29:48 -0400
Message-ID: <87vakvlx2b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57000 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754821AbdIFOdM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 10:33:12 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Getting the frames to the bridge as requested turned up an issue or
> three. The offload_fwd_mark is not being set by DSA, so the bridge
> floods the received frames back to the switch ports, resulting in
> duplication since the hardware has already flooded the packet. Fixing
> that turned up an issue with the meaning of
> SWITCHDEV_ATTR_ID_PORT_PARENT_ID in DSA. A DSA fabric of three
> switches needs to look to the software bridge as a single
> switch. Otherwise the offload_fwd_mark does not work, and we get
> duplication on the non-ingress switch. But each switch returned a
> different value. And they were not unique.

[...]

> Is the SWITCHDEV_ATTR_ID_PORT_PARENT_ID change acceptable?

So here we need to return the switch fabric (tree) ID instead of a
single switch chip ID. I think we are not supposed to change it, but
there's definitly something wrong with them and we must fix it.

The same issue happens with the physical port IDs, where the net devices
of two disjoint trees on a system will have the same phys_*_id
attributes, because we do not include the tree ID in them.

(not sure if this affects your patchset though.)


Thanks,

        Vivien
