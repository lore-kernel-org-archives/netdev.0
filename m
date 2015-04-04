From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 0/3] RDS: RDS-core fixes
Date: Sat,  4 Apr 2015 08:45:43 -0400
Message-ID: <cover.1428150441.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch-series updates the RDS core and rds-tcp modules with
some bug fixes that were originally authored by  Andy Grover,
Zach Brown, and Chris Mason.

v2: Code review comment by Sergei Shtylov
V3: DaveM comments:
- dropped patches 3, 5 for "heuristic" changes in rds_send_xmit(). 
  Investigation into the root-cause of these IB-triggered changes 
  produced the feedback: "I don't remember seeing "RDS: Stuck RM"
  message in last 1-1.5 years and checking with other folks. It may very
  well be some old workaround for stale connection for which long term
  fix is already made and this part of code not exercised anymore."

  Any such fixes, *if* they are needed, can/should be done in the
  IB specific RDS transport modules.

- similarly dropped the LL_SEND_FULL patch (patch 6 in v2 set)

Sowmini Varadhan (3):
  RDS: Re-add pf/sol access via sysctl
  RDS: only use passive connections when addresses match
  RDS: make sure not to loop forever inside rds_send_xmit

 net/rds/connection.c |    3 ++-
 net/rds/rds.h        |    1 +
 net/rds/send.c       |   33 +++++++++++++++++++++++++++++++--
 net/rds/sysctl.c     |   20 ++++++++++++++++++++
 4 files changed, 54 insertions(+), 3 deletions(-)
