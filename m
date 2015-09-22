From: Phil Sutter <phil@nwl.cc>
Subject: [iproute2 PATCH v2] man: tc.8: mention available qdiscs
Date: Tue, 22 Sep 2015 16:18:47 +0200
Message-ID: <1442931527-17659-1-git-send-email-phil@nwl.cc>
References: <20150921143048.071cea77@urahara>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:36356 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755847AbbIVOSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 10:18:49 -0400
In-Reply-To: <20150921143048.071cea77@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some qdiscs still lack a manpage, so listing them here is the only way
for a user to get to know them. For the others, this serves as an
overview of what is there.

Content was taken over from the dedicated manpage if available and
suitable, so there is definitely room for improvement at least by
adjusting it more to the context in which it is now. In case there
wasn't appropriate wording available, I tried to identify key aspects of
the given qdisc.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Added all remaining qdiscs which were not listed before and for which a file
  exists amongst tc/q_*.c.
- Changed subject line and comment to reflect the above.
---
 man/man8/tc.8 | 98 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 98 insertions(+)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index feafa05..9687840 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -147,20 +147,92 @@ qdiscs - they are not masters of what happens.
 .SH CLASSLESS QDISCS
 The classless qdiscs are:
 .TP
+choke
+CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for unresponsive
+flows) is a classless qdisc designed to both identify and penalize flows that
+monopolize the queue. CHOKe is a variation of RED, and the configuration is
+similar to RED.
+.TP
+codel
+CoDel (pronounced "coddle") is an adaptive "no-knobs" active queue management
+algorithm (AQM) scheme that was developed to address the shortcomings of
+RED and its variants.
+.TP
 [p|b]fifo
 Simplest usable qdisc, pure First In, First Out behaviour. Limited in
 packets or in bytes.
 .TP
+fq
+Fair Queue Scheduler realises TCP pacing and scales to millions of concurrent
+flows per qdisc.
+.TP
+fq_codel
+Fair Queuing Controlled Delay is queuing discipline that combines Fair
+Queuing with the CoDel AQM scheme. FQ_Codel uses a stochastic model to classify
+incoming packets into different flows and is used to provide a fair share of the
+bandwidth to all the flows using the queue. Each such flow is managed by the
+CoDel queuing discipline. Reordering within a flow is avoided since Codel
+internally uses a FIFO queue.
+.TP
+gred
+Generalized Random Early Detection combines multiple RED queues in order to
+achieve multiple drop priorities. This is required to realize Assured
+Forwarding (RFC 2597).
+.TP
+hhf
+Heavy-Hitter Filter differentiates between small flows and the opposite,
+heavy-hitters. The goal is to catch the heavy-hitters and move them to a
+separate queue with less priority so that bulk traffic does not affect the
+latency of critical traffic.
+.TP
+ingress
+This is a special qdisc as it applies to incoming traffic on an interface, allowing for it to be filtered and policed.
+.TP
+mqprio
+The Multiqueue Priority Qdisc is a simple queuing discipline that allows
+mapping traffic flows to hardware queue ranges using priorities and a
+configurable priority to traffic class mapping. A traffic class in this context
+is a set of contiguous qdisc classes which map 1:1 to a set of hardware exposed
+queues.
+.TP
+multiq
+Multiqueue is a qdisc optimized for devices with multiple Tx queues. It has
+been added for hardware that wishes to avoid head-of-line blocking.  It will
+cycle though the bands and verify that the hardware queue associated with the
+band is not stopped prior to dequeuing a packet.
+.TP
+netem
+Network Emulator is an enhancement of the Linux traffic control facilities that
+allow to add delay, packet loss, duplication and more other characteristics to
+packets outgoing from a selected network interface.
+.TP
 pfifo_fast
 Standard qdisc for 'Advanced Router' enabled kernels. Consists of a three-band
 queue which honors Type of Service flags, as well as the priority that may be
 assigned to a packet.
 .TP
+pie
+Proportional Integral controller-Enhanced (PIE) is a control theoretic active
+queue management scheme. It is based on the proportional integral controller but
+aims to control delay.
+.TP
 red
 Random Early Detection simulates physical congestion by randomly dropping
 packets when nearing configured bandwidth allocation. Well suited to very
 large bandwidth applications.
 .TP
+rr
+Round-Robin qdisc with support for multiqueue network devices. Removed from
+Linux since kernel version 2.6.27.
+.TP
+sfb
+Stochastic Fair Blue is a classless qdisc to manage congestion based on
+packet loss and link utilization history while trying to prevent
+non-responsive flows (i.e. flows that do not react to congestion marking
+or dropped packets) from impacting performance of responsive flows.
+Unlike RED, where the marking probability has to be configured, BLUE
+tries to determine the ideal marking probability automatically.
+.TP
 sfq
 Stochastic Fairness Queueing reorders queued traffic so each 'session'
 gets to send a packet in turn.
@@ -190,12 +262,31 @@ qdisc is the automatic default in the absence of a configured qdisc.
 .SH CLASSFUL QDISCS
 The classful qdiscs are:
 .TP
+ATM
+Map flows to virtual circuits of an underlying asynchronous transfer mode
+device.
+.TP
 CBQ
 Class Based Queueing implements a rich linksharing hierarchy of classes.
 It contains shaping elements as well as prioritizing capabilities. Shaping is
 performed using link idle time calculations based on average packet size and
 underlying link bandwidth. The latter may be ill-defined for some interfaces.
 .TP
+DRR
+The Deficit Round Robin Scheduler is a more flexible replacement for Stochastic
+Fairness Queuing. Unlike SFQ, there are no built-in queues \-\- you need to add
+classes and then set up filters to classify packets accordingly.  This can be
+useful e.g. for using RED qdiscs with different settings for particular
+traffic. There is no default class \-\- if a packet cannot be classified, it is
+dropped.
+.TP
+DSMARK
+Classify packets based on TOS field, change TOS field of packets based on
+classification.
+.TP
+HFSC
+Hierarchical Fair Service Curve guarantees precise bandwidth and delay allocation for leaf classes and allocates excess bandwidth fairly. Unlike HTB, it makes use of packet dropping to achieve low delays which interactive sessions benefit from.
+.TP
 HTB
 The Hierarchy Token Bucket implements a rich linksharing hierarchy of
 classes with an emphasis on conforming to existing practices. HTB facilitates
@@ -209,6 +300,13 @@ classes which are dequeued in order. This allows for easy prioritization
 of traffic, where lower classes are only able to send if higher ones have
 no packets available. To facilitate configuration, Type Of Service bits are
 honored by default.
+.TP
+QFQ
+Quick Fair Queueing is an O(1) scheduler that provides near-optimal guarantees,
+and is the first to achieve that goal with a constant cost also with respect to
+the number of groups and the packet length. The QFQ algorithm has no loops, and
+uses very simple instructions and data structures that lend themselves very
+well to a hardware implementation.
 .SH THEORY OF OPERATION
 Classes form a tree, where each class has a single parent.
 A class may have multiple children. Some qdiscs allow for runtime addition
-- 
2.5.0
