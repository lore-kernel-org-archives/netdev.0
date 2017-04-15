From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 0/3] sctp: add proper process for duplicated stream reconf requests
Date: Sat, 15 Apr 2017 22:00:26 +0800
Message-ID: <cover.1492264734.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33508 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdDOOAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 10:00:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp stream reconf will process a request again even if it's seqno
is less than asoc->strreset_inseq. It may cause a replay attack.

This patchset is to avoid it by add proper process for all duplicated
stream reconf requests.

Xin Long (3):
  sctp: process duplicated strreset out and addstrm out requests
    correctly
  sctp: process duplicated strreset in and addstrm in requests correctly
  sctp: process duplicated strreset asoc request correctly

 include/net/sctp/structs.h |  1 +
 net/sctp/stream.c          | 96 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 74 insertions(+), 23 deletions(-)

-- 
2.1.0
