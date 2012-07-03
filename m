From: <Parav.Pandit@Emulex.Com>
Subject: speed specific port cost calculation in br_if.c and how to make it
 generic based on 802.1d Table-17-3?
Date: Tue, 3 Jul 2012 12:40:26 +0000
Message-ID: <fb3586f4-ce51-4d38-a3a1-c9be04b2b131@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Parav.Pandit@Emulex.Com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17745 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177Ab2GCMkd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 08:40:33 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to add further support to bridging portion of stack for 40G and 100G speeds.
net/bridge/br_if.c function port_cost() has hard coded values of 2, 4, 19, 100 for speed of 10G, 1G, 100M, 10Mbps respectively.
Comment mentions about based on 802.1d standard.

I am referring to 802.1d-2004 Table 17-3-Port Path Cost values.
It mentions port cost value of 2000, 20000, 200000 respectively for speed of 10G, 1G, 100Mbps respectively.
This makes sense to me as the post cost value is inversely proportional and scalar function of its speed.

Can anyone please guide me on 
1. how the current calculation of path/port cost is being done so that I can enhance it for other speeds too in generic way if possible?
2. How can I incorporate for other speed settings in generic way based on 802.1a-2004 spec, Table 17-3?

Current code snippet:
/* Determine initial path cost based on speed.
 * using recommendations from 802.1d standard
 *
 * Since driver might sleep need to not be holding any locks.
 */
static int port_cost(struct net_device *dev)
{
        struct ethtool_cmd ecmd;

        if (!__ethtool_get_settings(dev, &ecmd)) {
                switch (ethtool_cmd_speed(&ecmd)) {
                case SPEED_10000:
                        return 2;
                case SPEED_1000:
                        return 4;
                case SPEED_100:
                        return 19;
                case SPEED_10:
                        return 100;
                }
        }

        /* Old silly heuristics based on name */
        if (!strncmp(dev->name, "lec", 3))
                return 7;

        if (!strncmp(dev->name, "plip", 4))
                return 2500;

        return 100;     /* assume old 10Mbps */
}

Regards,
Parav Pandit
