From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/6] net: dsa: Fix
 SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 27 Sep 2017 13:15:33 +0300
Message-ID: <847022b2-4bf7-0fbd-abf8-3d74af215933@cogentembedded.com>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:53129 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752659AbdI0KPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 06:15:40 -0400
Received: by mail-wr0-f173.google.com with SMTP id c23so15538854wrg.9
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 03:15:38 -0700 (PDT)
In-Reply-To: <1506464764-12699-2-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 9/27/2017 1:25 AM, Andrew Lunn wrote:

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

    s/of/have/?

> all ports of the cluster, not just the switch it originated
> from. Hence all ports of a cluster should return the same parent. The
> old implementation did not, each switch in the cluster had its own ID.
> 
> Also wrong was that the ID was not unique if multiple DSA instances
> are in operation.
> 
> Use the tree ID as the parent ID, which is the same for all switches
> in a cluster and unique across switch clusters.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v2: Swap from MAC address to dst->tree
[...]

MBR, Sergei
