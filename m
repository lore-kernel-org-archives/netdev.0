From: Martin Rusko <martin.rusko@gmail.com>
Subject: Sending undersized ARP packets with VXLAN L3 interface
Date: Wed, 27 Aug 2014 19:06:04 +0200
Message-ID: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:34991 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935246AbaH0RGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:06:05 -0400
Received: by mail-yh0-f54.google.com with SMTP id v1so524551yhn.41
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:06:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried to use VXLAN interface as an L3 interface. Something like this:

  ip link add name vxln7 \
  type vxlan id 7007 group 232.1.42.7 \
  local 10.7.12.250 dev vlan482 \
  dstport 0 ageing 300

  ip ad ad 192.168.3.200/24 brd + dev vxln7
  ip li set vxln7 up

Now this doesn't work very well for small packets like those carrying
ARP protocol. Because resulting ethernet frames which are encapsulated
in VXLAN are not padded to minimum 64bytes required for Ethernet. Once
the inner frame traverse through any switch, it will get dropped as
undersized (runt) packet.

I'm wondering, where is the proper place to fix this. Should
arp_create() function allocate skb big enough to produce ethernet
frame with at least minimum size? Or is it somewhere in NIC drivers
where small packets are padded with zeros?

Regards,
Martin
