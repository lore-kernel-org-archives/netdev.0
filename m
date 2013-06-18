From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/5] Further SCTP changes
Date: Tue, 18 Jun 2013 10:55:15 +0200
Message-ID: <1371545720-22950-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897Ab3FRIzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 04:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly it's all about getting rid of unnecessary code, and/or making
it more clean and readable.

Code has been tested with lksctp-tools functional test suite and
also my small sctp stress test helper that was used to discover
the recent null-ptr derefs. This test was also sucessfully run against
auth_enabled=0 and auth_enabled=1, where I also previously applied
the following two patches:

  - http://marc.info/?l=linux-crypto-vger&m=137121898331017&w=2
    -> not yet applied, still pending review for crypto tree
  - 1abd165 (net: sctp: fix NULL pointer dereference in socket destruction)
    -> cherry picked from net tree

Daniel Borkmann (5):
  net: sctp: remove TEST_FRAME ifdef
  ktime: add ms_to_ktime() and ktime_add_ms() helpers
  net: sctp: migrate cookie life from timeval to ktime
  net: sctp: decouple cleaning socket data from endpoint
  net: sctp: minor: sctp_seq_dump_local_addrs add missing newline

 include/linux/ktime.h      | 13 +++++++++++++
 include/net/sctp/sctp.h    | 25 -------------------------
 include/net/sctp/structs.h |  6 +++---
 net/sctp/associola.c       |  8 +-------
 net/sctp/endpointola.c     |  7 -------
 net/sctp/proc.c            |  2 +-
 net/sctp/sm_make_chunk.c   | 19 ++++++++-----------
 net/sctp/socket.c          | 34 ++++++++++++++++++++++------------
 8 files changed, 48 insertions(+), 66 deletions(-)

-- 
1.7.11.7
