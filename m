From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: bridge, packet destination not found in fdb, how to match in ebtables?
Date: Sat, 5 Jan 2008 08:51:11 +0200
Message-ID: <20080105062204.M26820@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:47798 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbYAEGv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 01:51:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

In few words: i have problem with bridge, that if some MAC address is not
known, even expired by age bridge will send packet as "flood".

If i am not wrong
in br_device.c
int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
...
        if (dest[0] & 1)
                br_flood_deliver(br, skb);
        else if ((dst = __br_fdb_get(br, dest)) != NULL)
                br_deliver(dst->dst, skb);
        else
                br_flood_deliver(br, skb);
...

Probably, because packet becoming broadcast in bridge terms, it is useful to
set it  something skb->pkt_type = PACKET_BROADCAST; ?
But as i understand after looking in kernel code it can't be set
PACKET_BROADCAST, because it will mess with most of network drivers. So packet
is in ebtables pkttype is matching as "otherhost", same as "good"(non-flood)
packets.


But is there a way to set "flood packet" to some type, that i can match in
ebtables and block it as broadcast?

I had with PPPoE troubles with this, cause PPPoE acting differently than
IP+ARP, and situation when some buggy linksys router start flooding network by
PADT packet to address not existing in fdb, just killing network by "flood" of
this frames to all ports.

Here i see two solutions:
1)Change pkt_type
2)Develop additional module to handle "fdb attributes" (destination found in
fdb or unknown)

I think it is relatively trivial to implement, and it will be useful, as usual
settings available on modern switches, known as "flood limit", but i think i
am not enough programmer to do that. If possible guide me what to do.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

