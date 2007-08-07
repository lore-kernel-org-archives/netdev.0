From: "Toshiyuki Okamoto" <okamoso@gmail.com>
Subject: IPsec IPv4 over IPv6 Problem: No route to host
Date: Tue, 7 Aug 2007 15:55:26 +0900
Message-ID: <a12e65340708062355o4374f215ie403acdcd84e0f39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:60554 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbXHGGz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 02:55:28 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1600741fkz
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 23:55:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Problem about IPsec IPv4 over IPv6, which is included in kernel 2.6.21.

A IPv6 global address is assigned for eth1 by DHCPv6 IA-PD. This case,
IPsec SA is successfully established but packets cannot been sent to WAN.

I do ping, this error occured:

 $ ping: sendmsg: No route to host

Do someone know about this issue ?

Network is figured below:
LAN                 WAN                 LAN
  |------ GW-1 -------|
  | eth1        eth0  |
                      |------ GW-2 -------|
                      |  eth0       eth1  |
                                          |
・GW-1
eth0      Link encap:Ethernet  HWaddr 00:11:43:AC:60:AF
         inet6 addr: fe80::211:43ff:feac:60af/64 Scope:Link

eth1      Link encap:Ethernet  HWaddr 00:90:CC:DE:8B:EE
         inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
         inet6 addr: 2001:1::290:ccff:fede:8bee/64 Scope:Global
         inet6 addr: fe80::290:ccff:fede:8bee/64 Scope:Link


・GW-2
eth0      Link encap:Ethernet  HWaddr 00:11:43:AB:00:8A
         inet6 addr: fe80::211:43ff:feab:8a/64 Scope:Link

eth1      Link encap:Ethernet  HWaddr 00:90:CC:DE:89:F7
         inet addr:192.168.2.1  Bcast:192.168.2.255  Mask:255.255.255.0
         inet6 addr: 2001:2::290:ccff:fede:89f7/64 Scope:Global
         inet6 addr: fe80::290:ccff:fede:89f7/64 Scope:Link

After IKE daemon (racoon2) is booted on GW-1/2, I do ping from GW-1:
 $ ping -I 192.168.1.1 192.168.2.1
This case, IKE sequence is successfully done, and IPsec SA is registered.
but ping packet isn't been sent with error above.

The case IPv6 global address is assigned to eth0 manually,
IPv4 over IPv6 packet is sent successfully.
ping6 between GW-1 and GW-2 is okay.

I suspect that IPv6 routing table is not loaded or invalid.

I tried that IPv6 global address is assigned to eth0 manually (which
prefix is varied to GW1/eth0 from GW2/eth0 with appropriate routing
set),
 IPv4 over IPv6 packet is not sent successfully.

Toshiyuki Okamoto (okamoso at gmail.com)
