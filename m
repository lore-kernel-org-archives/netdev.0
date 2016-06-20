From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 20 Jun 2016 11:25:01 +1000
Message-ID: <20160620112501.3365a03b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joshua Houghton <josh@awful.name>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/rds/tcp_connect.c

between commit:

  5c3da57d70f1 ("net: rds: fix coding style issues")

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

diff --cc net/rds/tcp_connect.c
index f6e95d60db54,ba9ec67f4e41..000000000000
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@@ -54,19 -55,20 +55,20 @@@ void rds_tcp_state_change(struct sock *
  
  	rdsdebug("sock %p state_change to %d\n", tc->t_sock, sk->sk_state);
  
 -	switch(sk->sk_state) {
 -		/* ignore connecting sockets as they make progress */
 -		case TCP_SYN_SENT:
 -		case TCP_SYN_RECV:
 -			break;
 -		case TCP_ESTABLISHED:
 -			rds_connect_path_complete(&conn->c_path[0],
 -						  RDS_CONN_CONNECTING);
 -			break;
 -		case TCP_CLOSE_WAIT:
 -		case TCP_CLOSE:
 -			rds_conn_drop(conn);
 -		default:
 -			break;
 +	switch (sk->sk_state) {
 +	/* ignore connecting sockets as they make progress */
 +	case TCP_SYN_SENT:
 +	case TCP_SYN_RECV:
 +		break;
 +	case TCP_ESTABLISHED:
- 		rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
++		rds_connect_path_complete(&conn->c_path[0],
++					  RDS_CONN_CONNECTING);
 +		break;
 +	case TCP_CLOSE_WAIT:
 +	case TCP_CLOSE:
 +		rds_conn_drop(conn);
 +	default:
 +		break;
  	}
  out:
  	read_unlock_bh(&sk->sk_callback_lock);
