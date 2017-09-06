From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 rfc 8/8] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 06 Sep 2017 10:46:48 -0400
Message-ID: <87d17351gn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <1504654510-31004-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58758 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdIFOuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 10:50:13 -0400
In-Reply-To: <1504654510-31004-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> SWITCHDEV_ATTR_ID_PORT_PARENT_ID is used by the software bridge when
> determining which ports to flood a packet out. If the packet
> originated from a switch, it assumes the switch has already flooded
> the packet out the switches ports, so the bridge should not flood the
> packet itself out switch ports. Ports on the same switch are expected
> to return the same parent ID when SWITCHDEV_ATTR_ID_PORT_PARENT_ID is
> called.
>
> DSA gets this wrong with clusters of switches. As far as the software
> bridge is concerned, the cluster is all one switch. A packet from any
> switch in the cluster can be assumed to of been flooded as needed out
> all ports of the cluster, not just the switch it originated
> from. Hence all ports of a cluster should return the same parent. The
> old implementation did not, each switch in the cluster had its own ID.
>
> Also wrong was that the ID was not unique if multiple DSA instances
> are in operation.
>
> Use the MAC address of the master interface as the parent ID. This is
> the same for all switches in a cluster, and should be unique if there
> are multiple clusters.

That is not correct. Support for multiple CPU ports is coming and in
this case, you can have two CPU host interfaces wired to two switch
ports of the same tree. So two different master MAC addresses.

Only the tree ID assigned by DSA core is unique to a given tree.


Thanks,

        Vivien
