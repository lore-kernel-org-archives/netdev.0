From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/7] sctp: add receiver-side procedures for stream reconf asoc reset and add streams and response
Date: Fri, 10 Mar 2017 12:11:05 +0800
Message-ID: <cover.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34784 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751619AbdCJEL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:11:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 2/7, 4/7, 5/7, 6/7 are to implement the process of asoc reset request,
add streams requests and all kinds of responses.

Patch 1/7 and 3/7 are ahead of 2/7 and 4/7 to add two event notification
for asoc reset and add streams.

Patch 7/7 is the last patch for implementing rfc6525 sctp stream reconf
to add sysctl and sockopt interface for users to enable sctp stream reconf.

After this patchset, sctp stream reconf will be able to work as rfc6525.

v1->v2:
  - put these into a smaller group.
  - rename the titles of the commits and improve some changelogs.
  - improve sctp_chunk_lookup_strreset_param and reuse it in patch 4/7.
  - process addstrm outreq as the ack of in addstrm inreq if strreset_chunk
    is not NULL in patch 4/7.
  - remove the stream alloc when sending addstrm inreq, and the process in
    peer will response it by sending a addstrm out request back in patch 5/7.
  - adjust the process of addstrm in resp to fit in the codes that only alloc
    streams through addstrm outreq in patch 6/7.

Xin Long (7):
  sctp: add support for generating assoc reset event notification
  sctp: implement receiver-side procedures for the SSN/TSN Reset Request
    Parameter
  sctp: add support for generating add stream change event notification
  sctp: implement receiver-side procedures for the Add Outgoing Streams
    Request Parameter
  sctp: implement receiver-side procedures for the Add Incoming Streams
    Request Parameter
  sctp: implement receiver-side procedures for the Reconf Response
    Parameter
  sctp: add get and set sockopt for reconf_enable

 include/net/sctp/sm.h       |  16 ++
 include/net/sctp/ulpevent.h |   8 +
 include/uapi/linux/sctp.h   |  31 ++++
 net/sctp/sm_statefuns.c     |  15 +-
 net/sctp/socket.c           |  81 +++++++++
 net/sctp/stream.c           | 396 +++++++++++++++++++++++++++++++++++++++++---
 net/sctp/sysctl.c           |   7 +
 net/sctp/ulpevent.c         |  56 +++++++
 8 files changed, 585 insertions(+), 25 deletions(-)

-- 
2.1.0
