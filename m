From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: sched_timeout() sets curr_state (net/)
Date: Sun, 5 Oct 2003 20:39:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005203906.2eadaac4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test6-current.

--
~Randy


From: Alexey Dobriyan <adobriyan@mail.ru>


 linux-260-test6-kj1-rddunlap/net/atm/resources.c        |    1 -
 linux-260-test6-kj1-rddunlap/net/bluetooth/hci_core.c   |    1 -
 linux-260-test6-kj1-rddunlap/net/ipv4/ipvs/ip_vs_sync.c |    2 --
 linux-260-test6-kj1-rddunlap/net/sunrpc/svcsock.c       |    1 -
 4 files changed, 5 deletions(-)

diff -puN net/atm/resources.c~net_all_taskrun net/atm/resources.c
--- linux-260-test6-kj1/net/atm/resources.c~net_all_taskrun	2003-09-29 17:34:55.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/net/atm/resources.c	2003-09-29 17:34:55.000000000 -0700
@@ -139,7 +139,6 @@ void atm_dev_deregister(struct atm_dev *
         while (atomic_read(&dev->refcnt) != 1) {
                 current->state = TASK_INTERRUPTIBLE;
                 schedule_timeout(HZ / 4);
-                current->state = TASK_RUNNING;
                 if ((jiffies - warning_time) > 10 * HZ) {
                         printk(KERN_EMERG "atm_dev_deregister: waiting for "
                                "dev %d to become free. Usage count = %d\n",
diff -puN net/bluetooth/hci_core.c~net_all_taskrun net/bluetooth/hci_core.c
--- linux-260-test6-kj1/net/bluetooth/hci_core.c~net_all_taskrun	2003-09-29 17:34:55.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/net/bluetooth/hci_core.c	2003-09-29 17:34:55.000000000 -0700
@@ -161,7 +161,6 @@ static int __hci_request(struct hci_dev 
 	req(hdev, opt);
 	schedule_timeout(timeout);
 
-	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&hdev->req_wait_q, &wait);
 
 	if (signal_pending(current))
diff -puN net/ipv4/ipvs/ip_vs_sync.c~net_all_taskrun net/ipv4/ipvs/ip_vs_sync.c
--- linux-260-test6-kj1/net/ipv4/ipvs/ip_vs_sync.c~net_all_taskrun	2003-09-29 17:34:55.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/net/ipv4/ipvs/ip_vs_sync.c	2003-09-29 17:34:55.000000000 -0700
@@ -669,7 +669,6 @@ static void sync_master_loop(void)
 
 		__set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(HZ);
-		__set_current_state(TASK_RUNNING);
 	}
 
 	/* clean up the sync_buff queue */
@@ -728,7 +727,6 @@ static void sync_backup_loop(void)
 
 		__set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(HZ);
-		__set_current_state(TASK_RUNNING);
 	}
 
 	/* release the sending multicast socket */
diff -puN net/sunrpc/svcsock.c~net_all_taskrun net/sunrpc/svcsock.c
--- linux-260-test6-kj1/net/sunrpc/svcsock.c~net_all_taskrun	2003-09-29 17:34:55.000000000 -0700
+++ linux-260-test6-kj1-rddunlap/net/sunrpc/svcsock.c	2003-09-29 17:34:55.000000000 -0700
@@ -1151,7 +1151,6 @@ svc_recv(struct svc_serv *serv, struct s
 		if (!p) {
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			schedule_timeout(HZ/2);
-			current->state = TASK_RUNNING;
 			continue;
 		}
 		rqstp->rq_argpages[rqstp->rq_arghi++] = p;

_
