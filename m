From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Tue, 20 Jan 2015 12:25:36 -0800
Message-ID: <1421785536-19793-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:54727 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753394AbbATVIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:08:52 -0500
Received: by mail-pd0-f182.google.com with SMTP id z10so5855562pdj.13
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:08:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series adds support for Stateless Transport
Tunneling protocol.
STT uses TCP segmentation offload available in most of NIC. On
packet xmit STT driver appends STT header along with TCP header
to the packet. For GSO packet GSO parameters are set according
to tunnel configuration and packet is handed over to networking
stack. This allows use of segmentation offload available in NICs

Netperf unidirectional test gives ~9.4 Gbits/s performance on 10Gbit
NIC with 1500 byte MTU with two TCP streams.

The protocol is documented at
http://www.ietf.org/archive/id/draft-davie-stt-06.txt

I will send out OVS userspace patch on ovs-dev mailing list.

Pravin B Shelar (3):
  skbuff: Add skb_list_linearize()
  net: Add STT tunneling protocol.
  openvswitch: Add support for STT tunneling.

 include/linux/skbuff.h           |    2 +
 include/net/stt.h                |   55 ++
 include/uapi/linux/openvswitch.h |    1 +
 net/core/skbuff.c                |   35 +
 net/ipv4/Kconfig                 |   11 +
 net/ipv4/Makefile                |    1 +
 net/ipv4/stt.c                   | 1386 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/Kconfig          |   10 +
 net/openvswitch/Makefile         |    1 +
 net/openvswitch/vport-stt.c      |  214 ++++++
 10 files changed, 1716 insertions(+)
 create mode 100644 include/net/stt.h
 create mode 100644 net/ipv4/stt.c
 create mode 100644 net/openvswitch/vport-stt.c

-- 
1.9.1
