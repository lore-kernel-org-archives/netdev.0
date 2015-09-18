From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/6] man: lnstat: rewrite manpage
Date: Fri, 18 Sep 2015 20:17:04 +0200
Message-ID: <1442600225-18355-6-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37195 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbbIRSRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:08 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/lnstat.8 | 197 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 192 insertions(+), 5 deletions(-)

diff --git a/man/man8/lnstat.8 b/man/man8/lnstat.8
index 699ddf4..69fe876 100644
--- a/man/man8/lnstat.8
+++ b/man/man8/lnstat.8
@@ -9,9 +9,21 @@ This manual page documents briefly the
 .B lnstat
 command.
 .PP
-\fBlnstat\fP is a generalized and more feature-complete replacement for the old rtstat program.
-In addition to routing cache statistics, it supports any kind of statistics the linux kernel
-exports via a file in /proc/net/stat/.
+\fBlnstat\fP is a generalized and more feature-complete replacement for the old
+rtstat program. It is commonly used to periodically print a selection of
+statistical values exported by the kernel.
+In addition to routing cache statistics, it supports any kind of statistics the
+linux kernel exports via a file in /proc/net/stat/.
+.PP
+Each file in /proc/net/stat/ contains a header line listing the column names.
+These names are used by \fBlnstat\fP as keys for selecting which statistics to
+print. For every CPU present in the system, a line follows which lists the
+actual values for each column of the file. \fBlnstat\fP sums these values up
+(which in fact are counters) before printing them. After each interval, only
+the difference to the last value is printed.
+.PP
+Files and columns may be selected by using the \fB-f\fP and \fB-k\fP
+parameters. By default, all columns of all files are printed.
 .SH OPTIONS
 lnstat supports the following options.
 .TP
@@ -28,7 +40,7 @@ Print <count> number of intervals.
 Dump list of available files/keys.
 .TP
 .B \-f, \-\-file <file>
-Statistics file to use.
+Statistics file to use, may be specified multiple times. By default all files in /proc/net/stat are scanned.
 .TP
 .B \-i, \-\-interval <intv>
 Set interval to 'intv' seconds.
@@ -37,7 +49,9 @@ Set interval to 'intv' seconds.
 Display results in JSON format
 .TP
 .B \-k, \-\-keys k,k,k,...
-Display only keys specified.
+Display only keys specified. Each key \fBk\fP is of the form \fB[file:]key\fP. If \fB<file>\fP
+is given, the search for the given key is limited to that file. Otherwise the first file containing
+the searched key is being used.
 .TP
 .B \-s, \-\-subject [0-2]
 Specify display of subject/header. '0' means no header at all, '1' prints a header only at start of the program and '2' prints a header every 20 lines.
@@ -66,6 +80,179 @@ Print a header at start and every 20 lines.
 .TP
 .B # lnstat -c -1 -i 1 -f rt_cache -k entries,in_hit,in_slow_tot
 Display statistics for keys entries, in_hit and in_slow_tot of field rt_cache every second.
+
+.SH FILES
+.TP
+.B /proc/net/stat/arp_cache, /proc/net/stat/ndisc_cache
+Statistics around neighbor cache and ARP. \fBarp_cache\fP is for IPv4, \fBndisc_cache\fP is the same for IPv6.
+.sp
+.B entries
+Number of entries in the neighbor table.
+.sp
+.B allocs
+How many neighbor entries have been allocated.
+.sp
+.B destroys
+How many neighbor entries have been removed.
+.sp
+.B hash_grows
+How often the neighbor (hash) table was increased.
+.sp
+.B lookups
+How many lookups were performed.
+.sp
+.B hits
+How many \fBlookups\fP were successful.
+.sp
+.B res_failed
+How many neighbor lookups failed.
+.sp
+.B rcv_probes_mcast
+How many multicast neighbor solicitations were received. (IPv6 only.)
+.sp
+.B rcv_probes_ucast
+How many unicast neighbor solicitations were received. (IPv6 only.)
+.sp
+.B periodic_gc_runs
+How many garbage collection runs were executed.
+.sp
+.B forced_gc_runs
+How many forced garbage collection runs were executed. Happens when adding an
+entry and the table is too full.
+.sp
+.B unresolved_discards
+How many neighbor table entries were discarded due to lookup failure.
+.sp
+.B table_fulls
+Number of table overflows. Happens if table is full and forced GC run (see
+\fBforced_gc_runs\fP) has failed.
+
+.TP
+.B /proc/net/stat/ip_conntrack, /proc/net/stat/nf_conntrack
+Conntrack related counters. \fBip_conntrack\fP is for backwards compatibility
+with older userspace only and shows the same data as \fBnf_conntrack\fP.
+.sp
+.B entries
+Number of entries in conntrack table.
+.sp
+.B searched
+Number of conntrack table lookups performed.
+.sp
+.B found
+Number of \fBsearched\fP entries which were successful.
+.sp
+.B new
+Number of conntrack entries added which were not expected before.
+.sp
+.B invalid
+Number of packets seen which can not be tracked.
+.sp
+.B ignore
+Number of packets seen which are already connected to a conntrack entry.
+.sp
+.B delete
+Number of conntrack entries which were removed.
+.sp
+.B delete_list
+Number of conntrack entries which were put to dying list.
+.sp
+.B insert
+Number of entries inserted into the list.
+.sp
+.B insert_failed
+Number of entries for which list insertion was attempted but failed (happens if
+the same entry is already present).
+.sp
+.B drop
+Number of packets dropped due to conntrack failure. Either new conntrack entry
+allocation failed, or protocol helper dropped the packet.
+.sp
+.B early_drop
+Number of dropped conntrack entries to make room for new ones, if maximum table
+size was reached.
+.sp
+.B icmp_error
+Number of packets wich could not be tracked due to error situation. This is a
+subset of \fBinvalid\fP.
+.sp
+.B expect_new
+Number of conntrack entries added after an expectation for them was already
+present.
+.sp
+.B expect_create
+Number of expectations added.
+.sp
+.B expect_delete
+Number of expectations deleted.
+.sp
+.B search_restart
+Number of conntrack table lookups which had to be restarted due to hashtable
+resizes.
+
+.TP
+.B /proc/net/stat/rt_cache
+Routing cache statistics.
+.sp
+.B entries
+Number of entries in routing cache.
+.sp
+.B in_hit
+Number of route cache hits for incoming packets. Deprecated since IP route
+cache removal, therefore always zero.
+.sp
+.B in_slow_tot
+Number of routing cache entries added for input traffic.
+.sp
+.B in_slow_mc
+Number of multicast routing cache entries added for input traffic.
+.sp
+.B in_no_route
+Number of input packets for which no routing table entry was found.
+.sp
+.B in_brd
+Number of matched input broadcast packets.
+.sp
+.B in_martian_dst
+Number of incoming martian destination packets.
+.sp
+.B in_martian_src
+Number of incoming martian source packets.
+.sp
+.B out_hit
+Number of route cache hits for outgoing packets. Deprecated since IP route
+cache removal, therefore always zero.
+.sp
+.B out_slow_tot
+Number of routing cache entries added for output traffic.
+.sp
+.B out_slow_mc
+Number of multicast routing cache entries added for output traffic.
+.sp
+.B gc_total
+Total number of garbage collection runs. Deprecated since IP route cache
+removal, therefore always zero.
+.sp
+.B gc_ignored
+Number of ignored garbage collection runs due to minimum GC interval not
+reached and routing cache not full. Deprecated since IP route cache removal,
+therefore always zero.
+.sp
+.B gc_goal_miss
+Number of garbage collector goal misses. Deprecated since IP route cache
+removal, therefore always zero.
+.sp
+.B gc_dst_overflow
+Number of destination cache overflows. Deprecated since IP route cache removal,
+therefore always zero.
+.sp
+.B in_hlist_search
+Number of hash table list traversals for input traffic. Deprecated since IP
+route cache removal, therefore always zero.
+.sp
+.B out_hlist_search
+Number of hash table list traversals for output traffic. Deprecated since IP
+route cache removal, therefore always zero.
+
 .SH SEE ALSO
 .BR ip (8),
 and /usr/share/doc/iproute-doc/README.lnstat (package iproute-doc on Debian)
-- 
2.1.2
