From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/6] sctp: fix the transmit err process
Date: Thu,  8 Sep 2016 17:31:44 +0800
Message-ID: <cover.1473326067.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36688 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758648AbcIHJb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 05:31:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to improve the transmit err process and also fix some
issues.

After this patchset, once the chunks are enqueued successfully, even
if the chunks fail to send out, no matter because of nodst or nomem,
no err retruns back to users any more. Instead, they are taken care
of by retransmit.

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
 net/sctp/outqueue.c        | 89 ++++++++++++++++------------------------------
 net/sctp/sm_sideeffect.c   | 25 +++++--------
 net/sctp/socket.c          |  6 ++--
 6 files changed, 84 insertions(+), 104 deletions(-)

-- 
2.1.0
