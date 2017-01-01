From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 00/27] sctp: implement rfc6525 sctp stream reconf
Date: Sun,  1 Jan 2017 19:20:17 +0800
Message-ID: <cover.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36347 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754991AbdAALUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:20:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to implement sctp stream reconf described in rfc6525.

Patch 1-3   add per stream information in sctp asoc.
Patch 4-8   make the chunk with different reconf params. (Section 3-4)
Patch 9-12  add reconf timer, primitive and enable option.
Patch 13-25 implement the procedures on both sender and receiver sides (Section 5)
            add sockopts and event for users (Section 6)
Patch 26-27 add reconf event, activate the sctp stream reconf process.

Xin Long (27):
  sctp: add stream arrays in asoc
  sctp: replace ssnmap with asoc stream arrays
  sctp: remove asoc ssnmap and ssnmap.c
  sctp: add rfc6525 section 3.1
  sctp: add rfc6525 section 4.1-4.2
  sctp: add rfc6525 section 4.3
  sctp: add rfc6525 section 4.4
  sctp: add rfc6525 section 4.5-4.6
  sctp: add stream reconf timer
  sctp: add stream reconf primitive
  sctp: add reconf_enable in asoc ep and netns
  sctp: add get and set sockopt for reconf_enable
  sctp: add rfc6525 section 6.3.1
  sctp: add rfc6525 section 5.1.2-5.1.3 and 6.3.2
  sctp: add rfc6525 section 5.1.4 and 6.3.3
  sctp: add rfc6525 section 5.1.5-5.1.6 and 6.3.4
  sctp: add rfc6525 section 6.1.1
  sctp: add rfc6525 section 6.1.2
  sctp: add rfc6525 section 6.1.3
  sctp: add rfc6525 section 5.2.2
  sctp: add rfc6525 section 5.2.3
  sctp: add rfc6525 section 5.2.4
  sctp: add rfc6525 section 5.2.5
  sctp: add rfc6525 section 5.2.6
  sctp: add rfc6525 section 5.2.7
  sctp: add sctp reconf chunk process
  sctp: add reconf chunk event

 include/linux/sctp.h         |  68 ++++++
 include/net/netns/sctp.h     |   3 +
 include/net/sctp/constants.h |   7 +-
 include/net/sctp/sctp.h      |   3 +-
 include/net/sctp/sm.h        |  54 ++++-
 include/net/sctp/structs.h   |  91 ++++---
 include/net/sctp/ulpevent.h  |  12 +
 include/uapi/linux/sctp.h    |  93 ++++++-
 net/sctp/Makefile            |   4 +-
 net/sctp/associola.c         |  29 ++-
 net/sctp/endpointola.c       |   1 +
 net/sctp/objcnt.c            |   2 -
 net/sctp/outqueue.c          |  33 ++-
 net/sctp/primitive.c         |   3 +
 net/sctp/sm_make_chunk.c     | 403 ++++++++++++++++++++++++++++++-
 net/sctp/sm_sideeffect.c     |  32 +++
 net/sctp/sm_statefuns.c      | 112 ++++++++-
 net/sctp/sm_statetable.c     |  70 ++++++
 net/sctp/socket.c            | 433 +++++++++++++++++++++++++++++++++
 net/sctp/ssnmap.c            | 125 ----------
 net/sctp/stream.c            | 563 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sysctl.c            |   7 +
 net/sctp/transport.c         |  17 +-
 net/sctp/ulpevent.c          |  86 +++++++
 net/sctp/ulpqueue.c          |  33 +--
 25 files changed, 2043 insertions(+), 241 deletions(-)
 delete mode 100644 net/sctp/ssnmap.c
 create mode 100644 net/sctp/stream.c

-- 
2.1.0
