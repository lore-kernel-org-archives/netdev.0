From: Rusty Russell <rusty@rustcorp.com.au>
Subject: cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_bits: net
Date: Tue, 30 Dec 2008 08:53:42 +1030
Message-ID: <200812300853.43035.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Mike Travis <travis@sgi.com>,
	Ingo Molnar <mingo@elte.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38483 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbYL2WXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 17:23:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: cleanup, future-proof

In future all cpumask ops will only be valid (in general) for bit
numbers < nr_cpu_ids.  So use that instead of NR_CPUS in iterators
and other comparisons.

This is always safe: no cpu number can be >= nr_cpu_ids, and
nr_cpu_ids is initialized to NR_CPUS at boot.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Ingo Molnar <mingo@elte.hu>
---
 net/core/neighbour.c                                  |    4 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 ++--
 net/ipv4/route.c                                      |    4 ++--
 net/netfilter/nf_conntrack_standalone.c               |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff -r bb80787e9617 net/core/neighbour.c
--- a/net/core/neighbour.c	Fri Oct 24 00:27:01 2008 +1100
+++ b/net/core/neighbour.c	Fri Oct 24 00:28:25 2008 +1100
@@ -2423,7 +2423,7 @@ static void *neigh_stat_seq_start(struct
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -2438,7 +2438,7 @@ static void *neigh_stat_seq_next(struct 
 	struct neigh_table *tbl = pde->data;
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
diff -r bb80787e9617 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c	Fri Oct 24 00:27:01 2008 +1100
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c	Fri Oct 24 00:28:25 2008 +1100
@@ -291,7 +291,7 @@ static void *ct_cpu_seq_start(struct seq
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -306,7 +306,7 @@ static void *ct_cpu_seq_next(struct seq_
 	struct net *net = seq_file_net(seq);
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
diff -r bb80787e9617 net/ipv4/route.c
--- a/net/ipv4/route.c	Fri Oct 24 00:27:01 2008 +1100
+++ b/net/ipv4/route.c	Fri Oct 24 00:28:25 2008 +1100
@@ -427,7 +427,7 @@ static void *rt_cpu_seq_start(struct seq
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
@@ -440,7 +440,7 @@ static void *rt_cpu_seq_next(struct seq_
 {
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
diff -r bb80787e9617 net/netfilter/nf_conntrack_standalone.c
--- a/net/netfilter/nf_conntrack_standalone.c	Fri Oct 24 00:27:01 2008 +1100
+++ b/net/netfilter/nf_conntrack_standalone.c	Fri Oct 24 00:28:25 2008 +1100
@@ -200,7 +200,7 @@ static void *ct_cpu_seq_start(struct seq
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for (cpu = *pos-1; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos-1; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
@@ -215,7 +215,7 @@ static void *ct_cpu_seq_next(struct seq_
 	struct net *net = seq_file_net(seq);
 	int cpu;
 
-	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+	for (cpu = *pos; cpu < nr_cpu_ids; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
