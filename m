From: Olaf Rempel <razzor@kopf-tisch.de>
Subject: [2.6.11 PATCH] /proc/net/stat/* cleanup
Date: Fri, 4 Mar 2005 20:37:51 +0100
Message-ID: <20050304203751.379dc6a6@coruscant>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi list

in /proc/net/stat/[arp|ndisc]_cache the value "forced_gc_goal_miss" has no
associated member in struct neigh_statistics.

in /proc/net/stat/rt_cache the value "in_slow_mc" was printed, but without header
(16 header-names, 17 values)

patch is against vanilla 2.6.11

Olaf

diff -uN linux-2.6.11/net/core/neighbour.c.org linux-2.6.11/net/core/neighbour.c
--- linux-2.6.11/net/core/neighbour.c.org       2005-03-04 20:03:01.000000000 +0100
+++ linux-2.6.11/net/core/neighbour.c   2005-03-04 20:04:17.000000000 +0100
@@ -1948,7 +1948,7 @@
        struct neigh_statistics *st = v;

        if (v == SEQ_START_TOKEN) {
-               seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs forced_gc_goal_miss\n");
+               seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs\n");
                return 0;
        }

diff -uN linux-2.6.11/net/ipv4/route.c.org linux-2.6.11/net/ipv4/route.c
--- linux-2.6.11/net/ipv4/route.c.org   2005-03-04 19:45:54.000000000 +0100
+++ linux-2.6.11/net/ipv4/route.c       2005-03-04 19:47:58.000000000 +0100
@@ -393,7 +393,7 @@
        struct rt_cache_stat *st = v;

        if (v == SEQ_START_TOKEN) {
-               seq_printf(seq, "entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+               seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
                return 0;
        }
