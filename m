From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/2] net: sched: act_tunnel_key: UDP checksums
Date: Wed, 14 Jun 2017 21:19:29 +0200
Message-ID: <cover.1497467840.git.jbenc@redhat.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751756AbdFNTYR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:24:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the tunnel_key tc action does not set TUNNEL_CSUM, thus
transmitting packets with zero UDP checksum. This is inconsistent with how
we treat non-lwt UDP tunnels where the default is to fill in the UDP
checksum. Non-zero UDP checksum is the better default anyway for various
reasons previously discussed.

Make this configurable for the tunnel_key tc action with the default being
non-zero checksum. Saves a lot of surprises especially with IPv6.

Signed-off-by: Jiri Benc <jbenc@redhat.com>


Jiri Benc (2):
  net: sched: act_tunnel_key: request UDP checksum by default
  net: sched: act_tunnel_key: make UDP checksum configurable

 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

-- 
1.8.3.1
