From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next v2 00/10] Introduce SCTP Stream Schedulers
Date: Tue,  3 Oct 2017 19:20:07 -0300
Message-ID: <cover.1507069005.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:50385 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdJCWUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces the SCTP Stream Schedulers are defined by
https://tools.ietf.org/html/draft-ietf-tsvwg-sctp-ndata-13

It provides 3 schedulers at the moment: FCFS, Priority and Round Robin.
The other 3, Round Robin per packet, Fair Capacity and Weighted Fair
Capacity will be added later. More specifically, WFQ is required by
WebRTC Datachannels.

The draft also defines the idata chunk, allowing a usermsg to be
interrupted by another piece of idata from another stream. This patchset
*doesn't* include it. It will be posted later by Xin Long.  Its
integration with this patchset is very simple and it basically only
requires a tweak in sctp_sched_dequeue_done(), to ignore datamsg
boundaries.

The first 5 patches are a preparation for the next ones. The most
relevant patches are the 4th and 6th ones. More details are available on
each patch.

v2: changelog update on patch 3

Marcelo Ricardo Leitner (10):
  sctp: silence warns on sctp_stream_init allocations
  sctp: factor out stream->out allocation
  sctp: factor out stream->in allocation
  sctp: introduce struct sctp_stream_out_ext
  sctp: introduce sctp_chunk_stream_no
  sctp: introduce stream scheduler foundations
  sctp: add sockopt to get/set stream scheduler
  sctp: add sockopt to get/set stream scheduler parameters
  sctp: introduce priority based stream scheduler
  sctp: introduce round robin stream scheduler

 include/net/sctp/stream_sched.h |  72 +++++++++
 include/net/sctp/structs.h      |  63 +++++++-
 include/uapi/linux/sctp.h       |  16 ++
 net/sctp/Makefile               |   3 +-
 net/sctp/chunk.c                |   6 +-
 net/sctp/outqueue.c             |  63 ++++----
 net/sctp/sm_sideeffect.c        |   3 +
 net/sctp/socket.c               | 179 ++++++++++++++++++++-
 net/sctp/stream.c               | 196 +++++++++++++++++++----
 net/sctp/stream_sched.c         | 275 +++++++++++++++++++++++++++++++
 net/sctp/stream_sched_prio.c    | 347 ++++++++++++++++++++++++++++++++++++++++
 net/sctp/stream_sched_rr.c      | 201 +++++++++++++++++++++++
 12 files changed, 1347 insertions(+), 77 deletions(-)
 create mode 100644 include/net/sctp/stream_sched.h
 create mode 100644 net/sctp/stream_sched.c
 create mode 100644 net/sctp/stream_sched_prio.c
 create mode 100644 net/sctp/stream_sched_rr.c

-- 
2.13.5
