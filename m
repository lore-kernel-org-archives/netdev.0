From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 27 Apr 2010 11:28:35 +1000
Message-ID: <20100427112835.f2b6662c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Christie <michaelc@cs.wisc.edu>,
	James Bottomley <James.Bottomley@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/scsi/iscsi_tcp.c between commit
d7d05548a62c87ee55b0c81933669177f885aa8d ("[SCSI] iscsi_tcp: fix
relogin/shutdown hang") from the  tree and commit
aa395145165cb06a0d0885221bbe0ce4a564391d ("net: sk_sleep() helper") from
the net tree.

I fixed it up (see below) and can carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/scsi/iscsi_tcp.c
index cdb4fd8,9eae04a..0000000
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@@ -601,9 -599,9 +601,9 @@@ static void iscsi_sw_tcp_conn_stop(stru
  	set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
  	write_unlock_bh(&tcp_sw_conn->sock->sk->sk_callback_lock);
  
- 	if (sock->sk->sk_sleep) {
 -	if (sk_sleep(sock->sk) && waitqueue_active(sk_sleep(sock->sk))) {
++	if (sk_sleep(sock->sk)) {
  		sock->sk->sk_err = EIO;
- 		wake_up_interruptible(sock->sk->sk_sleep);
+ 		wake_up_interruptible(sk_sleep(sock->sk));
  	}
  
  	iscsi_conn_stop(cls_conn, flag);
