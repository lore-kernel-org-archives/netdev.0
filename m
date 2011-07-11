From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Mon, 11 Jul 2011 16:16:40 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A040F7@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com><20110711130729.607d461e@nehalam.ftrdhcpuser.net><925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com><20110711134938.5178797c@nehalam.ftrdhcpuser.net><925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110711141028.19f0de46@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:23100 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab1GKVQl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:16:41 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The bridge code calls dev_set_promiscuity() which should
> be changing device mode. But it could be that netdev core is 
> resetting/changing/breaking that.

Is it supposed to change the physical ethnn devices or the br device?

Here is what I do to set up the bridging. I do it myself right in the
script so I can control all the details.

.
.
.
#
# Setup bridging
#

echo "Setting up bridge $BR_IFACE to bridge $INET_IFACE with
$TRUSTED1_IFACE"

$BRCTL addbr $BR_IFACE
$BRCTL addif $BR_IFACE $INET_IFACE
$BRCTL addif $BR_IFACE $TRUSTED1_IFACE

echo "  Adding $BR_IP_SLASH and $TRUSTED1_IP_SLASH IP Addresses to
$BR_IFACE"
/sbin/ip addr add $BR_IP_SLASH broadcast $BR_BCAST_ADDRESS dev $BR_IFACE
/sbin/ip addr add $TRUSTED1_IP_SLASH broadcast $TRUSTED1_BCAST_ADDRESS
dev $BR_IFACE
/sbin/ip link set $BR_IFACE up

echo "  Removing $INET_IP_SLASH and $TRUSTED1_IP_SLASH from $INET_IFACE
and $TRUSTED1_IFACE"
/sbin/ip addr del $INET_IP_SLASH dev $INET_IFACE
/sbin/ip addr del $INET_IP_SLASH dev $INET_IFACE
/sbin/ip addr del $TRUSTED1_IP_SLASH dev $TRUSTED1_IFACE
/sbin/ip addr del $TRUSTED1_IP_SLASH dev $TRUSTED1_IFACE

echo "  Putting $BR_IFACE into promiscuous mode"
# This fixes a bug forwarding packets bound for external IP Addresses
# from the private LAN.

ip link set $BR_IFACE promisc on

#
# Set up aliases for public IP addresses
#
.
.
.


- Greg


