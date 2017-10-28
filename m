From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/4] sctp: a bunch of fixes for some sparse warnings
Date: Sat, 28 Oct 2017 19:43:53 +0800
Message-ID: <cover.1509190967.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:50774 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdJ1LoG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:44:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Eric noticed, when running 'make C=2 M=net/sctp/', a plenty of
warnings or errors checked by sparse appear. They are all problems
about Endian and type cast.

Most of them are just warnings by which no issues could be caused
while some might be bugs.

This patchset fixes them with four patches basically according to
how they are introduced.

Xin Long (4):
  sctp: fix some type cast warnings introduced by stream reconf
  sctp: fix some type cast warnings introduced by transport rhashtable
  sctp: fix a type cast warnings that causes a_rwnd gets the wrong value
  sctp: fix some type cast warnings introduced since very beginning

 include/linux/sctp.h        | 34 +++++++++++++++++-----------------
 include/net/sctp/sm.h       |  2 +-
 include/net/sctp/ulpevent.h |  2 +-
 include/uapi/linux/sctp.h   |  2 +-
 net/sctp/input.c            | 22 +++++++++++-----------
 net/sctp/ipv6.c             |  2 +-
 net/sctp/sm_make_chunk.c    |  9 +++++----
 net/sctp/sm_sideeffect.c    |  8 ++++----
 net/sctp/stream.c           | 26 +++++++++++++++++---------
 net/sctp/ulpevent.c         |  2 +-
 10 files changed, 59 insertions(+), 50 deletions(-)

-- 
2.1.0
