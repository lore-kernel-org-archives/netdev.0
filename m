From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 0/7] sctp: add sender-side procedures for stream reconf ssn reset request chunk
Date: Sat, 14 Jan 2017 03:15:34 +0800
Message-ID: <cover.1484334002.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35241 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdAMTPt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 7/7 is to implement sender-side procedures for the Outgoing
and Incoming SSN Reset Request Parameter described in rfc6525
section 5.1.2 and 5.1.3

Patches 1-6/7 are ahead of it to define some apis and asoc members
for it.

Note that with this patchset, asoc->reconf_enable has no chance yet to
be set, until the patch "sctp: add get and set sockopt for reconf_enable"
is applied in the future. As we can not just enable it when sctp is not
capable of processing reconf chunk yet.

v1->v2:
  - put these into a smaller group.
  - rename some temporary variables in the codes.
  - rename the titles of the commits and improve some changelogs.
v2->v3:
  - re-split the patchset and make sure it has no dead codes for review.

Xin Long (7):
  sctp: add a common helper function to generate stream reconf chunk
  sctp: add support for generating stream reconf ssn reset request chunk
  sctp: add stream reconf timer
  sctp: add stream reconf primitive
  sctp: add reconf_enable in asoc ep and netns
  sctp: add sockopt SCTP_ENABLE_STREAM_RESET
  sctp: implement sender-side procedures for SSN Reset Request Parameter

 include/linux/sctp.h         |  32 ++++++++++
 include/net/netns/sctp.h     |   3 +
 include/net/sctp/constants.h |   4 +-
 include/net/sctp/sctp.h      |   8 +++
 include/net/sctp/sm.h        |   8 ++-
 include/net/sctp/structs.h   |  21 ++++++-
 include/uapi/linux/sctp.h    |  18 ++++++
 net/sctp/associola.c         |  12 ++++
 net/sctp/endpointola.c       |   1 +
 net/sctp/outqueue.c          |  33 +++++++----
 net/sctp/primitive.c         |   3 +
 net/sctp/protocol.c          |   3 +
 net/sctp/sm_make_chunk.c     | 136 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sm_sideeffect.c     |  32 ++++++++++
 net/sctp/sm_statefuns.c      |  41 +++++++++++++
 net/sctp/sm_statetable.c     |  40 +++++++++++++
 net/sctp/socket.c            | 113 +++++++++++++++++++++++++++++++++++
 net/sctp/stream.c            |  79 +++++++++++++++++++++++++
 net/sctp/transport.c         |  17 +++++-
 19 files changed, 588 insertions(+), 16 deletions(-)

-- 
2.1.0
