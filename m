From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 0/8] tc/act_pedit: Support offset relative to conventional header
Date: Sun, 23 Apr 2017 15:53:48 +0300
Message-ID: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33728 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045421AbdDWMye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id y10so1432123wmh.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

This patchset extends pedit to support modifying a field in an offset relative
to the conventional network headers (kenrel support was added [1] in 4.11 rc1).
Without the extended pedit, user could specify fields in TCP and ICMP headers,
but the kernel code was using an offset relative to the begining of the IP
header. This will break if IP header length is greater than the minimal value
of 20, or if L3 is not IPv4.

It also introduces support in manipulating ETH, TCP, UDP and IP.ttl fields and
a new command to increase/decrease the value of a field (current use case is IP.ttl).

Since there might be deployments already using pedit, special consideration was
taken, not to break those scripts - only by specifying the special keyword
'ex', the extended capabilities are available, thus there should be no impact
on existing scripts.
Also, the new code can live together with rules added by the old code. It
supports both the old netlink and the new one.

This patchset is against the master and not net-next as the functionality was
added in 4.11

Thanks,
Amir

[1] - 71d0ed7079df ("net/act_pedit: Support using offset relative to the
                     conventional network headers")

Amir Vadai (7):
  tc/pedit: Fix a typo in pedit usage message
  tc/pedit: Extend pedit to specify offset relative to mac/transport
    headers
  tc/pedit: Introduce 'add' operation
  tc/pedit: p_ip: introduce editing ttl header
  tc/pedit: Support fields bigger than 32 bits
  tc/pedit: p_eth: ETH header editor
  tc/pedit: p_tcp: introduce pedit tcp support

Or Gerlitz (1):
  tc/pedit: p_udp: introduce pedit udp support

 man/man8/tc-pedit.8 | 126 +++++++++++++++++++++--
 tc/Makefile         |   1 +
 tc/m_pedit.c        | 290 ++++++++++++++++++++++++++++++++++++++++++++++------
 tc/m_pedit.h        |  44 ++++++--
 tc/p_eth.c          |  72 +++++++++++++
 tc/p_icmp.c         |   3 +-
 tc/p_ip.c           |  21 +++-
 tc/p_tcp.c          |  40 +++++++-
 tc/p_udp.c          |  30 +++++-
 9 files changed, 572 insertions(+), 55 deletions(-)
 create mode 100644 tc/p_eth.c

-- 
2.12.0
