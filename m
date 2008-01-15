From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [APPLETALK]: Annotations to clear sparse warnings
Date: Tue, 15 Jan 2008 12:10:20 +0100
Message-ID: <20080115121020.6a0b0cfd.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58352 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112AbYAOLKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 06:10:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CHECK   net/appletalk/aarp.c
net/appletalk/aarp.c:951:14: warning: context imbalance in 'aarp_seq_start' - wrong count at exit
net/appletalk/aarp.c:977:13: warning: context imbalance in 'aarp_seq_stop' - unexpected unlock
  CHECK   net/appletalk/atalk_proc.c
net/appletalk/atalk_proc.c:34:11: warning: context imbalance in 'atalk_seq_interface_start' - wrong count at exit
net/appletalk/atalk_proc.c:54:13: warning: context imbalance in 'atalk_seq_interface_stop' - unexpected unlock
net/appletalk/atalk_proc.c:93:11: warning: context imbalance in 'atalk_seq_route_start' - wrong count at exit
net/appletalk/atalk_proc.c:113:13: warning: context imbalance in 'atalk_seq_route_stop' - unexpected unlock
net/appletalk/atalk_proc.c:161:11: warning: context imbalance in 'atalk_seq_socket_start' - wrong count at exit
net/appletalk/atalk_proc.c:178:13: warning: context imbalance in 'atalk_seq_socket_stop' - unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/appletalk/aarp.c       |    2 ++
 net/appletalk/atalk_proc.c |    6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index b950fb6..18058bb 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -941,6 +941,7 @@ static struct aarp_entry *iter_next(struct aarp_iter_state *iter, loff_t *pos)
 }
 
 static void *aarp_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(aarp_lock)
 {
 	struct aarp_iter_state *iter = seq->private;
 
@@ -975,6 +976,7 @@ static void *aarp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void aarp_seq_stop(struct seq_file *seq, void *v)
+	__releases(aarp_lock)
 {
 	read_unlock_bh(&aarp_lock);
 }
diff --git a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
index 05d9652..8e8dcfd 100644
--- a/net/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -27,6 +27,7 @@ static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
 }
 
 static void *atalk_seq_interface_start(struct seq_file *seq, loff_t *pos)
+	__acquires(atalk_interfaces_lock)
 {
 	loff_t l = *pos;
 
@@ -52,6 +53,7 @@ out:
 }
 
 static void atalk_seq_interface_stop(struct seq_file *seq, void *v)
+	__releases(atalk_interfaces_lock)
 {
 	read_unlock_bh(&atalk_interfaces_lock);
 }
@@ -86,6 +88,7 @@ static __inline__ struct atalk_route *atalk_get_route_idx(loff_t pos)
 }
 
 static void *atalk_seq_route_start(struct seq_file *seq, loff_t *pos)
+	__acquires(atalk_routes_lock)
 {
 	loff_t l = *pos;
 
@@ -111,6 +114,7 @@ out:
 }
 
 static void atalk_seq_route_stop(struct seq_file *seq, void *v)
+	__releases(atalk_routes_lock)
 {
 	read_unlock_bh(&atalk_routes_lock);
 }
@@ -154,6 +158,7 @@ found:
 }
 
 static void *atalk_seq_socket_start(struct seq_file *seq, loff_t *pos)
+	__acquires(atalk_sockets_lock)
 {
 	loff_t l = *pos;
 
@@ -176,6 +181,7 @@ out:
 }
 
 static void atalk_seq_socket_stop(struct seq_file *seq, void *v)
+	__releases(atalk_sockets_lock)
 {
 	read_unlock_bh(&atalk_sockets_lock);
 }
