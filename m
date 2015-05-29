From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 0/3] net/rds: SOL_RDS socket option to explicitly select transport
Date: Fri, 29 May 2015 17:28:06 -0400
Message-ID: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today the underlying transport (TCP or IB) for a PF_RDS socket is
implicitly selected based on the local address used to bind(2) the
PF_RDS socket. This results in some non-deterministic behavior when
there are un-numbered and IPoIB interfaces sharing the same IP address.
It also places the constraint that the IB interface must have an IP
address (and thus, IPoIB) configured on it.

The non-determinism may be avoided by providing the user-space application
a socket option that allows it to explicitly select the transport
prior to bind(2).

Patch 1 of this series provides the constant definitions needed by
the application via <linux/rds.h>.

Patch 2 provides the setsockopt support, and Patch 3 provides the
getsockopt support.

Sowmini Varadhan (3):
  Declare SO_RDS_TRANSPORT and RDS_TRANS_* constants in
    uapi/linux/rds.h
  Add setsockopt support for SO_RDS_TRANSPORT
  Add setsockopt support for SO_RDS_TRANSPORT

 include/uapi/linux/rds.h |   10 ++++++++++
 net/rds/af_rds.c         |   41 +++++++++++++++++++++++++++++++++++++++++
 net/rds/bind.c           |    4 ++++
 net/rds/rds.h            |    6 +-----
 net/rds/transport.c      |   21 +++++++++++++++++++++
 5 files changed, 77 insertions(+), 5 deletions(-)
