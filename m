From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH RFC] 2.4.18+ cache align some tcp globals
Date: Sun, 26 May 2002 20:09:08 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0205262000510.23603-100000@w-nivedita2.des.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

This makes some of the tcp globals cache aligned in
SMP systems  (trying to address cacheline bouncing
on busy systems).

Patch applies to 2.4.18.

thanks,
Nivedita


--- tcp.c	Fri Dec 21 09:42:05 2001
+++ tcp.c.new	Sun May 26 19:55:45 2002
@@ -266,20 +266,22 @@
 kmem_cache_t *tcp_bucket_cachep;
 kmem_cache_t *tcp_timewait_cachep;
 
-atomic_t tcp_orphan_count = ATOMIC_INIT(0);
+atomic_t tcp_orphan_count ____cacheline_aligned_in_smp = ATOMIC_INIT(0);
 
 int sysctl_tcp_mem[3];
 int sysctl_tcp_wmem[3] = { 4*1024, 16*1024, 128*1024 };
 int sysctl_tcp_rmem[3] = { 4*1024, 87380, 87380*2 };
 
-atomic_t tcp_memory_allocated;	/* Current allocated memory. */
-atomic_t tcp_sockets_allocated;	/* Current number of TCP sockets. */
+/* Current allocated memory. */
+atomic_t tcp_memory_allocated ____cacheline_aligned_in_smp;
+/* Current number of TCP sockets. */
+atomic_t tcp_sockets_allocated ____cacheline_aligned_in_smp;
 
 /* Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the tcp_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency. */
-int tcp_memory_pressure;
+int tcp_memory_pressure ____cacheline_aligned_in_smp;
 
 #define TCP_PAGES(amt) (((amt)+TCP_MEM_QUANTUM-1)/TCP_MEM_QUANTUM)
 
