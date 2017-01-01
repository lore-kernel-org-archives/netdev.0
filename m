From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 0/2] TPACKET_V3 TX_RING support
Date: Sun,  1 Jan 2017 14:45:13 -0800
Message-ID: <cover.1483309545.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35244 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbdAAWpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 17:45:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series allows an application to use a single PF_PACKET
descriptor and leverage the best implementations of TX_RING
and RX_RING that exist today.

Updates in v2 are listed below:

- patch 1 (which builds on the earlier patch discussed at
  http://patchwork.ozlabs.org/patch/709840/) verifies that tp_next_offset
  is set to 0 for TPACKET_V3 in the tpacket_snd path, indicating that
  variable-sized frames are not in use. Applications that wish to do
  block-sends must fill up multiple frames in the Tx ring and then
  trigger the transmit. At the current time, only fixed-size frames are
  supported on TX_RING for TPACKET_V3.

- patch 2 in this series adds a test case and sample code for
  (TPACKET_V3, PACKET_TX_RING) in testing/selftests

Sowmini Varadhan (2):
  af_packet: TX_RING support for TPACKET_V3
  tools: test case for TPACKET_V3/TX_RING support

 Documentation/networking/packet_mmap.txt    |    9 ++-
 net/packet/af_packet.c                      |   27 +++++--
 tools/testing/selftests/net/psock_tpacket.c |  110 ++++++++++++++++++++++++++-
 3 files changed, 135 insertions(+), 11 deletions(-)
