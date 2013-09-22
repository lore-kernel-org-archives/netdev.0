From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/12] rose.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:21 -0700
Message-ID: <bf9a479a278ce071f22b3f54662d452bddd884f1.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/rose.h | 114 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 60 insertions(+), 54 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index 555dd19..50811fe 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -160,38 +160,42 @@ extern int  sysctl_rose_routing_control;
 extern int  sysctl_rose_link_fail_timeout;
 extern int  sysctl_rose_maximum_vcs;
 extern int  sysctl_rose_window_size;
-extern int  rosecmp(rose_address *, rose_address *);
-extern int  rosecmpm(rose_address *, rose_address *, unsigned short);
-extern char *rose2asc(char *buf, const rose_address *);
-extern struct sock *rose_find_socket(unsigned int, struct rose_neigh *);
-extern void rose_kill_by_neigh(struct rose_neigh *);
-extern unsigned int rose_new_lci(struct rose_neigh *);
-extern int  rose_rx_call_request(struct sk_buff *, struct net_device *, struct rose_neigh *, unsigned int);
-extern void rose_destroy_socket(struct sock *);
+
+int rosecmp(rose_address *, rose_address *);
+int rosecmpm(rose_address *, rose_address *, unsigned short);
+char *rose2asc(char *buf, const rose_address *);
+struct sock *rose_find_socket(unsigned int, struct rose_neigh *);
+void rose_kill_by_neigh(struct rose_neigh *);
+unsigned int rose_new_lci(struct rose_neigh *);
+int rose_rx_call_request(struct sk_buff *, struct net_device *,
+			 struct rose_neigh *, unsigned int);
+void rose_destroy_socket(struct sock *);
 
 /* rose_dev.c */
-extern void  rose_setup(struct net_device *);
+void rose_setup(struct net_device *);
 
 /* rose_in.c */
-extern int  rose_process_rx_frame(struct sock *, struct sk_buff *);
+int rose_process_rx_frame(struct sock *, struct sk_buff *);
 
 /* rose_link.c */
-extern void rose_start_ftimer(struct rose_neigh *);
-extern void rose_stop_ftimer(struct rose_neigh *);
-extern void rose_stop_t0timer(struct rose_neigh *);
-extern int  rose_ftimer_running(struct rose_neigh *);
-extern void rose_link_rx_restart(struct sk_buff *, struct rose_neigh *, unsigned short);
-extern void rose_transmit_clear_request(struct rose_neigh *, unsigned int, unsigned char, unsigned char);
-extern void rose_transmit_link(struct sk_buff *, struct rose_neigh *);
+void rose_start_ftimer(struct rose_neigh *);
+void rose_stop_ftimer(struct rose_neigh *);
+void rose_stop_t0timer(struct rose_neigh *);
+int rose_ftimer_running(struct rose_neigh *);
+void rose_link_rx_restart(struct sk_buff *, struct rose_neigh *,
+			  unsigned short);
+void rose_transmit_clear_request(struct rose_neigh *, unsigned int,
+				 unsigned char, unsigned char);
+void rose_transmit_link(struct sk_buff *, struct rose_neigh *);
 
 /* rose_loopback.c */
-extern void rose_loopback_init(void);
-extern void rose_loopback_clear(void);
-extern int  rose_loopback_queue(struct sk_buff *, struct rose_neigh *);
+void rose_loopback_init(void);
+void rose_loopback_clear(void);
+int rose_loopback_queue(struct sk_buff *, struct rose_neigh *);
 
 /* rose_out.c */
-extern void rose_kick(struct sock *);
-extern void rose_enquiry_response(struct sock *);
+void rose_kick(struct sock *);
+void rose_enquiry_response(struct sock *);
 
 /* rose_route.c */
 extern struct rose_neigh *rose_loopback_neigh;
@@ -199,43 +203,45 @@ extern const struct file_operations rose_neigh_fops;
 extern const struct file_operations rose_nodes_fops;
 extern const struct file_operations rose_routes_fops;
 
-extern void rose_add_loopback_neigh(void);
-extern int __must_check rose_add_loopback_node(rose_address *);
-extern void rose_del_loopback_node(rose_address *);
-extern void rose_rt_device_down(struct net_device *);
-extern void rose_link_device_down(struct net_device *);
-extern struct net_device *rose_dev_first(void);
-extern struct net_device *rose_dev_get(rose_address *);
-extern struct rose_route *rose_route_free_lci(unsigned int, struct rose_neigh *);
-extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *, unsigned char *, int);
-extern int  rose_rt_ioctl(unsigned int, void __user *);
-extern void rose_link_failed(ax25_cb *, int);
-extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
-extern void rose_rt_free(void);
+void rose_add_loopback_neigh(void);
+int __must_check rose_add_loopback_node(rose_address *);
+void rose_del_loopback_node(rose_address *);
+void rose_rt_device_down(struct net_device *);
+void rose_link_device_down(struct net_device *);
+struct net_device *rose_dev_first(void);
+struct net_device *rose_dev_get(rose_address *);
+struct rose_route *rose_route_free_lci(unsigned int, struct rose_neigh *);
+struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *,
+				  unsigned char *, int);
+int rose_rt_ioctl(unsigned int, void __user *);
+void rose_link_failed(ax25_cb *, int);
+int rose_route_frame(struct sk_buff *, ax25_cb *);
+void rose_rt_free(void);
 
 /* rose_subr.c */
-extern void rose_clear_queues(struct sock *);
-extern void rose_frames_acked(struct sock *, unsigned short);
-extern void rose_requeue_frames(struct sock *);
-extern int  rose_validate_nr(struct sock *, unsigned short);
-extern void rose_write_internal(struct sock *, int);
-extern int  rose_decode(struct sk_buff *, int *, int *, int *, int *, int *);
-extern int  rose_parse_facilities(unsigned char *, unsigned int, struct rose_facilities_struct *);
-extern void rose_disconnect(struct sock *, int, int, int);
+void rose_clear_queues(struct sock *);
+void rose_frames_acked(struct sock *, unsigned short);
+void rose_requeue_frames(struct sock *);
+int rose_validate_nr(struct sock *, unsigned short);
+void rose_write_internal(struct sock *, int);
+int rose_decode(struct sk_buff *, int *, int *, int *, int *, int *);
+int rose_parse_facilities(unsigned char *, unsigned int,
+			  struct rose_facilities_struct *);
+void rose_disconnect(struct sock *, int, int, int);
 
 /* rose_timer.c */
-extern void rose_start_heartbeat(struct sock *);
-extern void rose_start_t1timer(struct sock *);
-extern void rose_start_t2timer(struct sock *);
-extern void rose_start_t3timer(struct sock *);
-extern void rose_start_hbtimer(struct sock *);
-extern void rose_start_idletimer(struct sock *);
-extern void rose_stop_heartbeat(struct sock *);
-extern void rose_stop_timer(struct sock *);
-extern void rose_stop_idletimer(struct sock *);
+void rose_start_heartbeat(struct sock *);
+void rose_start_t1timer(struct sock *);
+void rose_start_t2timer(struct sock *);
+void rose_start_t3timer(struct sock *);
+void rose_start_hbtimer(struct sock *);
+void rose_start_idletimer(struct sock *);
+void rose_stop_heartbeat(struct sock *);
+void rose_stop_timer(struct sock *);
+void rose_stop_idletimer(struct sock *);
 
 /* sysctl_net_rose.c */
-extern void rose_register_sysctl(void);
-extern void rose_unregister_sysctl(void);
+void rose_register_sysctl(void);
+void rose_unregister_sysctl(void);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
