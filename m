From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v4 0/3] RDS: RDS-core fixes
Date: Tue,  7 Apr 2015 16:38:01 -0400
Message-ID: <cover.1428437150.git.sowmini.varadhan@oracle.com>
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

v4: Documentation/networking/rds.txt contains incorrect references 
    to "missing sysctl values for pf_rds and sol_rds in mainline". 
    The sysctl values were never needed in mainline, thus fix the
    documentation.

Sowmini Varadhan (3):
  Document AF_RDS, PF_RDS and SOL_RDS correctly.
  RDS: only use passive connections when addresses match
  RDS: make sure not to loop forever inside rds_send_xmit

 Documentation/networking/rds.txt |    9 ++++-----
 net/rds/connection.c             |    3 ++-
 net/rds/rds.h                    |    1 +
 net/rds/send.c                   |   33 +++++++++++++++++++++++++++++++--
 4 files changed, 38 insertions(+), 8 deletions(-)
