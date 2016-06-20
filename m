From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 20 Jun 2016 11:28:07 +1000
Message-ID: <20160620112807.3665143f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:44328 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbcFTB2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2016 21:28:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/rds/tcp_listen.c

between commit:

  3bb549ae4c51 ("RDS: TCP: rds_tcp_accept_one() should transition socket from RESETTING to UP")

from the net tree and commit:

  0cb43965d42a ("RDS: split out connection specific state from rds_connection to rds_conn_path")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/rds/tcp_listen.c
index 245542ca4718,22d9bb15f731..000000000000
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@@ -136,9 -137,10 +137,10 @@@ int rds_tcp_accept_one(struct socket *s
  			goto rst_nsk;
  		} else {
  			rds_tcp_reset_callbacks(new_sock, conn);
- 			conn->c_outgoing = 0;
+ 			conn->c_path[0].cp_outgoing = 0;
  			/* rds_connect_path_complete() marks RDS_CONN_UP */
- 			rds_connect_path_complete(conn, RDS_CONN_RESETTING);
+ 			rds_connect_path_complete(&conn->c_path[0],
 -						  RDS_CONN_DISCONNECTING);
++						  RDS_CONN_RESETTING);
  		}
  	} else {
  		rds_tcp_set_callbacks(new_sock, conn);
