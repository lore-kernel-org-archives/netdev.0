From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Issue with LACP mode support in Linux bonding driver
Date: Wed, 24 Jun 2015 15:25:14 +0530
Message-ID: <CADAe=+LERY5jgVLpVdteFQXhcJdHzNxJpj=9t7Nyf0YTmSXcYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:32991 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbbFXJzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 05:55:55 -0400
Received: by obpn3 with SMTP id n3so23485011obp.0
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 02:55:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using Centos7 with v3.10 kernel.

My issue is related to multiaggregation in LACP.

In my setup topology I connected linux server and a L2 switch back to
back with 2 interfaces eth0 and eth1 (on both sides).

On Switch I have mapped eth0 to po1 and eth1 to po2. On linux server I
have created a single bond interface with both interfaces eth0 and
eth1.

On L2 switch both po1 and po2 has same system-id but the Actor key is
different i.e. on PO1 it is 16385 and on PO2 it is 32768. As per the
information available about bond0 on linux server which is given below
Active aggregator ID is 1 which is mapped to eth0 but eth1.

But we have observed that eth1 on linux server is also sending LACPDUS
with Collecting/Distributing bit set as 1. Which will result in single
bond interface on Linux server is splitted into multiple port-channels
on Switch causing duplication of frames on linux server.

As per IEEE 802.3ad 2003 standard portchannel should not support
multi-aggregation.


#  cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: fast
Min links: 0
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
    Aggregator ID: 1
    Number of ports: 1
    Actor Key: 17
    Partner Key: 16385
    Partner Mac Address: 11:11:22:22:33:33

Slave Interface: eth0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:18:ae:4b
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:76:35:a2
Aggregator ID: 3
Slave queue ID: 0


Regards,
Ajith
