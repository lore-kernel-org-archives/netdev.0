From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] cut'n' paste bug in fold_field()
Date: Fri, 7 Feb 2003 09:55:35 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0302070940200.1829-100000@dyn9-47-18-86.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Attached is a small patch for a cut'n'paste bug in linux 2.5.59
   net/ipv4/proc.c:fold_field()
This causes some /proc/net counters that are incremented in BH to be counted
twice and the counters incremented in user context not counted. 

--- proc.c      Tue Jan 21 17:18:52 2003
+++ proc.c.new  Fri Feb  7 09:39:34 2003
@@ -99,7 +99,7 @@
                    *((unsigned long *) (((void *) per_cpu_ptr(mib[0], i)) +
                                         sizeof (unsigned long) * nr));
                res +=
-                   *((unsigned long *) (((void *) per_cpu_ptr(mib[0], i)) +
+                   *((unsigned long *) (((void *) per_cpu_ptr(mib[1], i)) +
                                         sizeof (unsigned long) * nr));
        }
        return res;

The same routine(fold_field()) is duplicated in net/ipv6/proc.c, but it doesn't
have the bug.
Could we convert this to a static inline and move to a header file to avoid
the duplication and 'sctp' too can use it.

Thanks
Sridhar
