From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/6] Further SCTP changes
Date: Tue, 25 Jun 2013 17:13:35 +0200
Message-ID: <1372173221-15244-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab3FYPNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 11:13:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly it's all about getting rid of unnecessary code, and/or making
it more clean and readable. Code has been tested with lksctp-tools
functional test suite and also my small sctp stress test helper that
was used to discover the recent null-ptr derefs.

Changes since last version:
  - Left sctp_put_port() still in sctp_endpoint_destroy() for now
  - Added minor "net: sctp: simplify sctp_get_port" patch

Daniel Borkmann (6):
  net: sctp: remove TEST_FRAME ifdef
  ktime: add ms_to_ktime() and ktime_add_ms() helpers
  net: sctp: migrate cookie life from timeval to ktime
  net: sctp: minor: sctp_seq_dump_local_addrs add missing newline
  net: sctp: decouple cleaning some socket data from endpoint
  net: sctp: simplify sctp_get_port

 include/linux/ktime.h      | 13 +++++++++++++
 include/net/sctp/sctp.h    | 25 -------------------------
 include/net/sctp/structs.h |  6 +++---
 net/sctp/associola.c       |  8 +-------
 net/sctp/endpointola.c     | 18 +++++++++---------
 net/sctp/proc.c            |  2 +-
 net/sctp/sm_make_chunk.c   | 19 ++++++++-----------
 net/sctp/socket.c          | 35 +++++++++++++++++++----------------
 8 files changed, 54 insertions(+), 72 deletions(-)

-- 
1.7.11.7
