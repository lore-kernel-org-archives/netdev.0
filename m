From: Jon Smirl <jonsmirl@gmail.com>
Subject: pcap and ARP hardware type for IEEE 802.15.4
Date: Fri, 30 Jul 2010 10:05:09 -0400
Message-ID: <AANLkTin-7qNQSLPqtBOosByw5iM3Zaqxgz2Er-uT41bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:45217 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756593Ab0G3OFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 10:05:14 -0400
Received: by pxi14 with SMTP id 14so538281pxi.19
        for <netdev@vger.kernel.org>; Fri, 30 Jul 2010 07:05:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on pcap support for the native IEEE 802.15.4
implementation in the kernel.
http://sourceforge.net/apps/trac/linux-zigbee/

pcap uses ARPHRD_ to write the DLT value into the pcap file. We need a
new DLT for the internal Linux packets since they have had the two FCS
bytes stripped from the end.

The 802.15.4 implementation has used two different ARPHRD types, one
for the active interface and one for the monitor interface. Has that
been done correctly? Should there be two types?

void ieee802154_monitor_setup(struct net_device *dev)
{
       struct ieee802154_sub_if_data *priv;

       dev->addr_len           = 0;
       dev->features           = NETIF_F_NO_CSUM;
       dev->hard_header_len    = 0;
       dev->needed_tailroom    = 2; /* FCS */
       dev->mtu                = 127;
       dev->tx_queue_len       = 10;
       dev->type               = ARPHRD_IEEE802154_MONITOR;
       dev->flags              = IFF_NOARP | IFF_BROADCAST;
       dev->watchdog_timeo     = 0;

       dev->destructor         = free_netdev;
       dev->netdev_ops         = &ieee802154_monitor_ops;
       dev->ml_priv            = &mac802154_mlme;


void ieee802154_wpan_setup(struct net_device *dev)
{
       struct ieee802154_sub_if_data *priv;

       dev->addr_len           = IEEE802154_ADDR_LEN;
       memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
       dev->features           = NETIF_F_NO_CSUM;
       dev->hard_header_len    = 2 + 1 + 20 + 14;
       dev->header_ops         = &ieee802154_header_ops;
       dev->needed_tailroom    = 2; /* FCS */
       dev->mtu                = 1280;
       dev->tx_queue_len       = 10;
       dev->type               = ARPHRD_IEEE802154;
       dev->flags              = IFF_NOARP | IFF_BROADCAST;
       dev->watchdog_timeo     = 0;

       dev->destructor         = free_netdev;
       dev->netdev_ops         = &ieee802154_wpan_ops;
       dev->ml_priv            = &mac802154_mlme;




-- 
Jon Smirl
jonsmirl@gmail.com
