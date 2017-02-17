From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/7] sctp: add receiver-side procedures for stream reconf ssn reset request chunk
Date: Fri, 17 Feb 2017 12:45:36 +0800
Message-ID: <cover.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34489 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755352AbdBQEpw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:45:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 3/7 and 4/7 are to implement receiver-side procedures for the
Outgoing and Incoming SSN Reset Request Parameter described in rfc6525
section 5.2.2 and 5.2.3

Patch 1/7 and 2/7 are ahead of them to define some apis.

Patch 5/7-7/7 are to add the process of reconf chunk event in rx path.

Note that with this patchset, asoc->reconf_enable has no chance yet to
be set, until the patch "sctp: add get and set sockopt for reconf_enable"
is applied in the future. As we can not just enable it when sctp is not
capable of processing reconf chunk yet.

v1->v2:
  - re-split the patchset and make sure it has no dead codes for review.
  - rename the titles of the commits and improve some changelogs.
  - drop __packed from some structures in patch 1/7.
  - fix some kbuild warnings in patch 3/7 by initializing str_p = NULL.
  - sctp_chunk_lookup_strreset_param changes to return sctp_paramhdr_t *
    and uses sctp_strreset_tsnreq to access request_seq in patch 3/7.
  - use __u<size> in uapi sctp.h in patch 1/7.
  - do str_list endian conversion when generating stream_reset_event in patch
    2/7.
  - remove str_list endian conversion, pass resp_seq param with network endian
    to lookup_strreset_param in 3/7.
  - move str_list endian conversion out of sctp_make_strreset_req, so that
    sctp_make_strreset_req can be used more conveniently to process inreq in
    patch 4/7.
  - remove sctp_merge_reconf_chunk and not support response with multiparam
    in patch 6/7.

Xin Long (7):
  sctp: add support for generating stream reconf resp chunk
  sctp: add support for generating stream ssn reset event notification
  sctp: implement receiver-side procedures for the Outgoing SSN Reset
    Request Parameter
  sctp: implement receiver-side procedures for the Incoming SSN Reset
    Request Parameter
  sctp: add a function to verify the sctp reconf chunk
  sctp: add reconf chunk process
  sctp: add reconf chunk event

 include/linux/sctp.h         |  24 ++++++
 include/net/sctp/constants.h |   3 +
 include/net/sctp/sm.h        |  21 +++++
 include/net/sctp/ulpevent.h  |   4 +
 include/uapi/linux/sctp.h    |  16 ++++
 net/sctp/sm_make_chunk.c     | 141 +++++++++++++++++++++++++++++++--
 net/sctp/sm_statefuns.c      |  54 +++++++++++++
 net/sctp/sm_statetable.c     |  30 +++++++
 net/sctp/stream.c            | 183 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/ulpevent.c          |  29 +++++++
 10 files changed, 498 insertions(+), 7 deletions(-)

-- 
2.1.0
