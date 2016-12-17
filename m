From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] ATM: use designated initializers
Date: Fri, 16 Dec 2016 16:58:43 -0800
Message-ID: <20161217005843.GA140202@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Kees Cook <keescook@chromium.org>,
        Florian Westphal <fw@strlen.de>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36183 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758401AbcLQA6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:58:46 -0500
Received: by mail-pf0-f174.google.com with SMTP id 189so16363285pfz.3
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 16:58:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, with most initializer fixes
extracted from grsecurity.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/atm/lec.c                                |  6 ++--
 net/atm/mpoa_caches.c                        | 43 ++++++++++++++--------------
 net/vmw_vsock/vmci_transport_notify.c        | 30 +++++++++----------
 net/vmw_vsock/vmci_transport_notify_qstate.c | 30 +++++++++----------
 4 files changed, 54 insertions(+), 55 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 779b3fa6052d..019557d0a11d 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -111,9 +111,9 @@ static inline void lec_arp_put(struct lec_arp_table *entry)
 }
 
 static struct lane2_ops lane2_ops = {
-	lane2_resolve,		/* resolve,             spec 3.1.3 */
-	lane2_associate_req,	/* associate_req,       spec 3.1.4 */
-	NULL			/* associate indicator, spec 3.1.5 */
+	.resolve = lane2_resolve,		/* spec 3.1.3 */
+	.associate_req = lane2_associate_req,	/* spec 3.1.4 */
+	.associate_indicator = NULL             /* spec 3.1.5 */
 };
 
 static unsigned char bus_mac[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 9e60e74c807d..a89fdebeffda 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -535,33 +535,32 @@ static void eg_destroy_cache(struct mpoa_client *mpc)
 
 
 static const struct in_cache_ops ingress_ops = {
-	in_cache_add_entry,               /* add_entry       */
-	in_cache_get,                     /* get             */
-	in_cache_get_with_mask,           /* get_with_mask   */
-	in_cache_get_by_vcc,              /* get_by_vcc      */
-	in_cache_put,                     /* put             */
-	in_cache_remove_entry,            /* remove_entry    */
-	cache_hit,                        /* cache_hit       */
-	clear_count_and_expired,          /* clear_count     */
-	check_resolving_entries,          /* check_resolving */
-	refresh_entries,                  /* refresh         */
-	in_destroy_cache                  /* destroy_cache   */
+	.add_entry = in_cache_add_entry,
+	.get = in_cache_get,
+	.get_with_mask = in_cache_get_with_mask,
+	.get_by_vcc = in_cache_get_by_vcc,
+	.put = in_cache_put,
+	.remove_entry = in_cache_remove_entry,
+	.cache_hit = cache_hit,
+	.clear_count = clear_count_and_expired,
+	.check_resolving = check_resolving_entries,
+	.refresh = refresh_entries,
+	.destroy_cache = in_destroy_cache
 };
 
 static const struct eg_cache_ops egress_ops = {
-	eg_cache_add_entry,               /* add_entry        */
-	eg_cache_get_by_cache_id,         /* get_by_cache_id  */
-	eg_cache_get_by_tag,              /* get_by_tag       */
-	eg_cache_get_by_vcc,              /* get_by_vcc       */
-	eg_cache_get_by_src_ip,           /* get_by_src_ip    */
-	eg_cache_put,                     /* put              */
-	eg_cache_remove_entry,            /* remove_entry     */
-	update_eg_cache_entry,            /* update           */
-	clear_expired,                    /* clear_expired    */
-	eg_destroy_cache                  /* destroy_cache    */
+	.add_entry = eg_cache_add_entry,
+	.get_by_cache_id = eg_cache_get_by_cache_id,
+	.get_by_tag = eg_cache_get_by_tag,
+	.get_by_vcc = eg_cache_get_by_vcc,
+	.get_by_src_ip = eg_cache_get_by_src_ip,
+	.put = eg_cache_put,
+	.remove_entry = eg_cache_remove_entry,
+	.update = update_eg_cache_entry,
+	.clear_expired = clear_expired,
+	.destroy_cache = eg_destroy_cache
 };
 
-
 void atm_mpoa_init_cache(struct mpoa_client *mpc)
 {
 	mpc->in_ops = &ingress_ops;
diff --git a/net/vmw_vsock/vmci_transport_notify.c b/net/vmw_vsock/vmci_transport_notify.c
index fd8cf0214d51..1406db4d97d1 100644
--- a/net/vmw_vsock/vmci_transport_notify.c
+++ b/net/vmw_vsock/vmci_transport_notify.c
@@ -662,19 +662,19 @@ static void vmci_transport_notify_pkt_process_negotiate(struct sock *sk)
 
 /* Socket control packet based operations. */
 const struct vmci_transport_notify_ops vmci_transport_notify_pkt_ops = {
-	vmci_transport_notify_pkt_socket_init,
-	vmci_transport_notify_pkt_socket_destruct,
-	vmci_transport_notify_pkt_poll_in,
-	vmci_transport_notify_pkt_poll_out,
-	vmci_transport_notify_pkt_handle_pkt,
-	vmci_transport_notify_pkt_recv_init,
-	vmci_transport_notify_pkt_recv_pre_block,
-	vmci_transport_notify_pkt_recv_pre_dequeue,
-	vmci_transport_notify_pkt_recv_post_dequeue,
-	vmci_transport_notify_pkt_send_init,
-	vmci_transport_notify_pkt_send_pre_block,
-	vmci_transport_notify_pkt_send_pre_enqueue,
-	vmci_transport_notify_pkt_send_post_enqueue,
-	vmci_transport_notify_pkt_process_request,
-	vmci_transport_notify_pkt_process_negotiate,
+	.socket_init = vmci_transport_notify_pkt_socket_init,
+	.socket_destruct = vmci_transport_notify_pkt_socket_destruct,
+	.poll_in = vmci_transport_notify_pkt_poll_in,
+	.poll_out = vmci_transport_notify_pkt_poll_out,
+	.handle_notify_pkt = vmci_transport_notify_pkt_handle_pkt,
+	.recv_init = vmci_transport_notify_pkt_recv_init,
+	.recv_pre_block = vmci_transport_notify_pkt_recv_pre_block,
+	.recv_pre_dequeue = vmci_transport_notify_pkt_recv_pre_dequeue,
+	.recv_post_dequeue = vmci_transport_notify_pkt_recv_post_dequeue,
+	.send_init = vmci_transport_notify_pkt_send_init,
+	.send_pre_block = vmci_transport_notify_pkt_send_pre_block,
+	.send_pre_enqueue = vmci_transport_notify_pkt_send_pre_enqueue,
+	.send_post_enqueue = vmci_transport_notify_pkt_send_post_enqueue,
+	.process_request = vmci_transport_notify_pkt_process_request,
+	.process_negotiate = vmci_transport_notify_pkt_process_negotiate,
 };
diff --git a/net/vmw_vsock/vmci_transport_notify_qstate.c b/net/vmw_vsock/vmci_transport_notify_qstate.c
index 21e591dafb03..f3a0afc46208 100644
--- a/net/vmw_vsock/vmci_transport_notify_qstate.c
+++ b/net/vmw_vsock/vmci_transport_notify_qstate.c
@@ -420,19 +420,19 @@ vmci_transport_notify_pkt_send_pre_enqueue(
 
 /* Socket always on control packet based operations. */
 const struct vmci_transport_notify_ops vmci_transport_notify_pkt_q_state_ops = {
-	vmci_transport_notify_pkt_socket_init,
-	vmci_transport_notify_pkt_socket_destruct,
-	vmci_transport_notify_pkt_poll_in,
-	vmci_transport_notify_pkt_poll_out,
-	vmci_transport_notify_pkt_handle_pkt,
-	vmci_transport_notify_pkt_recv_init,
-	vmci_transport_notify_pkt_recv_pre_block,
-	vmci_transport_notify_pkt_recv_pre_dequeue,
-	vmci_transport_notify_pkt_recv_post_dequeue,
-	vmci_transport_notify_pkt_send_init,
-	vmci_transport_notify_pkt_send_pre_block,
-	vmci_transport_notify_pkt_send_pre_enqueue,
-	vmci_transport_notify_pkt_send_post_enqueue,
-	vmci_transport_notify_pkt_process_request,
-	vmci_transport_notify_pkt_process_negotiate,
+	.socket_init = vmci_transport_notify_pkt_socket_init,
+	.socket_destruct = vmci_transport_notify_pkt_socket_destruct,
+	.poll_in = vmci_transport_notify_pkt_poll_in,
+	.poll_out = vmci_transport_notify_pkt_poll_out,
+	.handle_notify_pkt = vmci_transport_notify_pkt_handle_pkt,
+	.recv_init = vmci_transport_notify_pkt_recv_init,
+	.recv_pre_block = vmci_transport_notify_pkt_recv_pre_block,
+	.recv_pre_dequeue = vmci_transport_notify_pkt_recv_pre_dequeue,
+	.recv_post_dequeue = vmci_transport_notify_pkt_recv_post_dequeue,
+	.send_init = vmci_transport_notify_pkt_send_init,
+	.send_pre_block = vmci_transport_notify_pkt_send_pre_block,
+	.send_pre_enqueue = vmci_transport_notify_pkt_send_pre_enqueue,
+	.send_post_enqueue = vmci_transport_notify_pkt_send_post_enqueue,
+	.process_request = vmci_transport_notify_pkt_process_request,
+	.process_negotiate = vmci_transport_notify_pkt_process_negotiate,
 };
-- 
2.7.4


-- 
Kees Cook
Nexus Security
