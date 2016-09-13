From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 0/6] sctp: fix the transmit err process
Date: Wed, 14 Sep 2016 02:04:17 +0800
Message-ID: <cover.1473789537.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35839 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbcIMSEe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:04:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to improve the transmit err process and also fix some
issues.

After this patchset, once the chunks are enqueued successfully, even
if the chunks fail to send out, no matter because of nodst or nomem,
no err retruns back to users any more. Instead, they are taken care
of by retransmit.

v1->v2:
  - add more details to the changelog in patch 1/6
  - add Fixes: tag in patch 2/6, 3/6
  - also revert 69b5777f2e57 in patch 3/6

Xin Long (6):
  sctp: remove the unnecessary state check in sctp_outq_tail
  sctp: do not return the transmit err back to sctp_sendmsg
  sctp: free msg->chunks when sctp_primitive_SEND return err
  sctp: save transmit error to sk_err in sctp_outq_flush
  sctp: make sctp_outq_flush/tail/uncork return void
  sctp: not return ENOMEM err back in sctp_packet_transmit

 include/net/sctp/structs.h |  5 +--
 net/sctp/chunk.c           | 13 +++++++
 net/sctp/output.c          | 50 +++++++++++++-------------
 net/sctp/outqueue.c        | 88 ++++++++++++++++------------------------------
 net/sctp/sm_sideeffect.c   | 25 +++++--------
 net/sctp/socket.c          |  8 +++--
 6 files changed, 85 insertions(+), 104 deletions(-)

-- 
2.1.0
