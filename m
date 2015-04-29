From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/7] net: Eliminate calls to flow_dissector and introduce flow_keys_digest
Date: Tue, 28 Apr 2015 21:27:34 -0700
Message-ID: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@resnulli.us>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46953 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbbD2E2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:28:02 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3T4PX9L002536
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2nmngeeu-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:01 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 1dd0520eee2811e49d4f0002c9521c9e-971d42c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 21:27:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch set we add skb_get_hash_perturb which gets the skbuff
hash for a packet and perturbs it using a provided key and jhash1.
This function is used in serveral qdiscs and eliminates many calls
to flow_dissector and jhash3 to get a perturbed hash for a packet.

To handle the sch_choke issue (passes flow_keys in skbuff cb) we
add flow_keys_digest which is a digest of a flow constructed
from a flow_keys structure.

This is the second version of these patches I posted a while ago,
and is prerequisite work to increasing the size of the flow_keys
structure and hashing over it (full IPv6 address, flow label, VLAN ID,
etc.).

Tom Herbert (7):
  net: Add skb_get_hash_perturb
  sched: Eliminate use of flow_keys in sch_fq_codel
  sched: Eliminate use of flow_keys in sch_hhf
  sched: Eliminate use of flow_keys in sch_sfb
  sched: Eliminate use of flow_keys in sch_sfq
  net: Add flow_keys digest
  sch_choke: Use flow_keys_digest

 include/linux/skbuff.h   | 15 +++++++++++++++
 include/net/flow_keys.h  | 19 +++++++++++++++++++
 net/sched/sch_choke.c    | 14 ++++----------
 net/sched/sch_fq_codel.c | 11 ++---------
 net/sched/sch_hhf.c      | 19 +------------------
 net/sched/sch_sfb.c      | 24 ++++++++----------------
 net/sched/sch_sfq.c      | 29 +++--------------------------
 7 files changed, 52 insertions(+), 79 deletions(-)

-- 
1.8.1
