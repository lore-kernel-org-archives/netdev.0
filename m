From: Nitin Sharma <nitinics@gmail.com>
Subject: arp_ip_target on mode balance-xor xmit_hash_policy layer3+4
Date: Thu, 9 Apr 2015 10:19:38 -0400
Message-ID: <CANqkpFK5ZS-YizNbKDPGK1ToTGZmqXNEoO8MW7uYMO5LyCo_0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36040 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbDIOTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 10:19:39 -0400
Received: by obbeb7 with SMTP id eb7so107248296obb.3
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 07:19:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Posting in netdev, since bonding-devel looks like isnt active anymore.

Has anyone got arp_ip_target to work on mode=2 i.e. balance-xor
layer3+4 xmit mode?

Here is my bonding_opts

mode=2 xmit_hash_policy=layer3+4 arp_ip_target=10.0.0.62 arp_interval=30000

I see from tcpdump that arp requests to 10.0.0.62 are sent to both
links, and both arp replies are got back too. However, bond0 shows
"NO-CARRIER".

Few things specific to my environment if these affect.

1. NOARP flag is set for bond0 - should it affect? I removed that
NOARP flag, and still the same behavior.
2. the arp_ip_target is also the gateway ip address of the host. There
is a default route to 10.0.0.62 on the hosts routing table.
3. Two switches reply to the same arp_tpa 10.0.0.62 arp request with different
mac-addresses. Essentially all I want from arp_ip_target is the receipt
of an ARP reply such that the bonding keeps the link on its transmit
decision, not necessary populate the arp table on the host.

Thanks
Nitin
