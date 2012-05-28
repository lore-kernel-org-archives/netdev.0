From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 1/2] tc(8): Negative indent and missing "-" after an escape
Date: Mon, 28 May 2012 13:46:04 +0200
Message-ID: <1338205565-11872-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Bjarni Ingi Gislason <bjarniig@rhi.hi.is>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:54713 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab2E1LnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 07:43:11 -0400
Received: from ipb5.telenor.se (ipb5.telenor.se [195.54.127.168])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 754D514A95
	for <netdev@vger.kernel.org>; Mon, 28 May 2012 13:43:08 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjarni Ingi Gislason <bjarniig@rhi.hi.is>

>From "man ..." ("groff -ww -mandoc ..."):

<groff: tc.8>:51: warning: total indent cannot be negative
<groff: tc.8>:57: warning: escape character ignored before `i'

*********************

Space at end of line removed

  General considerations

a) Manuals should usually only be left justified.  Use ".ad l"
as the first regular command.

b) Each sentence should begin on a new line.  The conventions
about the amount of space between sentences are different.  This
also makes a check on the number of space characters between
words easier.

c) Separate numbers from units with a (no-break) space.  A
no-break space can be code 0xA0, "\ " (\<space>), or "\~"
(groff).

d) Use macros "TS/TE" for tables with more than two columns.
Then use

'\" t

as the first line in the source to tell "man" to use the "tbl"
preprocessor.

e) Protect last period (full stop) in abbreviations with "\&",
if it is or might be (through new formatting of source) at the
end of line, if it is also not an end of sentence.

*********************

Originally filed at: http://bugs.debian.org/674704

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 man/man8/tc.8 |  178 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 89 insertions(+), 89 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index fc8095e..6576377 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -2,22 +2,22 @@
 .SH NAME
 tc \- show / manipulate traffic control settings
 .SH SYNOPSIS
-.B tc qdisc [ add | change | replace | link ] dev 
-DEV 
-.B 
-[ parent 
-qdisc-id 
-.B | root ] 
-.B [ handle 
+.B tc qdisc [ add | change | replace | link ] dev
+DEV
+.B
+[ parent
+qdisc-id
+.B | root ]
+.B [ handle
 qdisc-id ] qdisc
 [ qdisc specific parameters ]
 .P
 
 .B tc class [ add | change | replace ] dev
 DEV
-.B parent 
-qdisc-id 
-.B [ classid 
+.B parent
+qdisc-id
+.B [ classid
 class-id ] qdisc
 [ qdisc specific parameters ]
 .P
@@ -36,38 +36,38 @@ flow-id
 
 .B tc
 .RI "[ " FORMAT " ]"
-.B qdisc show [ dev 
-DEV 
+.B qdisc show [ dev
+DEV
 .B  ]
 .P
-.B tc 
+.B tc
 .RI "[ " FORMAT " ]"
-.B class show dev 
-DEV 
+.B class show dev
+DEV
 .P
-.B tc filter show dev 
-DEV 
+.B tc filter show dev
+DEV
 
-.ti -8
+.ti 8
 .IR FORMAT " := {"
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-d\fR[\fIetails\fR] |
 \fB\-r\fR[\fIaw\fR] |
 \fB\-p\fR[\fIretty\fR] |
-\fB\i\fR[\fIec\fR] }
+\fB\-i\fR[\fIec\fR] }
 
 .SH DESCRIPTION
 .B Tc
-is used to configure Traffic Control in the Linux kernel. Traffic Control consists 
+is used to configure Traffic Control in the Linux kernel. Traffic Control consists
 of the following:
 
-.TP 
+.TP
 SHAPING
-When traffic is shaped, its rate of transmission is under control. Shaping may 
-be more than lowering the available bandwidth - it is also used to smooth out 
+When traffic is shaped, its rate of transmission is under control. Shaping may
+be more than lowering the available bandwidth - it is also used to smooth out
 bursts in traffic for better network behaviour. Shaping occurs on egress.
 
-.TP 
+.TP
 SCHEDULING
 By scheduling the transmission of packets it is possible to improve interactivity
 for traffic that needs it while still guaranteeing bandwidth to bulk transfers. Reordering
@@ -80,34 +80,34 @@ arriving. Policing thus occurs on ingress.
 
 .TP
 DROPPING
-Traffic exceeding a set bandwidth may also be dropped forthwith, both on 
+Traffic exceeding a set bandwidth may also be dropped forthwith, both on
 ingress and on egress.
 
 .P
-Processing of traffic is controlled by three kinds of objects: qdiscs, 
-classes and filters. 
+Processing of traffic is controlled by three kinds of objects: qdiscs,
+classes and filters.
 
 .SH QDISCS
-.B qdisc 
-is short for 'queueing discipline' and it is elementary to 
-understanding traffic control. Whenever the kernel needs to send a 
-packet to an interface, it is 
+.B qdisc
+is short for 'queueing discipline' and it is elementary to
+understanding traffic control. Whenever the kernel needs to send a
+packet to an interface, it is
 .B enqueued
 to the qdisc configured for that interface. Immediately afterwards, the kernel
 tries to get as many packets as possible from the qdisc, for giving them
 to the network adaptor driver.
 
-A simple QDISC is the 'pfifo' one, which does no processing at all and is a pure 
+A simple QDISC is the 'pfifo' one, which does no processing at all and is a pure
 First In, First Out queue. It does however store traffic when the network interface
 can't handle it momentarily.
 
 .SH CLASSES
-Some qdiscs can contain classes, which contain further qdiscs - traffic may 
+Some qdiscs can contain classes, which contain further qdiscs - traffic may
 then be enqueued in any of the inner qdiscs, which are within the
 .B classes.
-When the kernel tries to dequeue a packet from such a 
+When the kernel tries to dequeue a packet from such a
 .B classful qdisc
-it can come from any of the classes. A qdisc may for example prioritize 
+it can come from any of the classes. A qdisc may for example prioritize
 certain kinds of traffic by trying to dequeue from certain classes
 before others.
 
@@ -117,45 +117,45 @@ A
 is used by a classful qdisc to determine in which class a packet will
 be enqueued. Whenever traffic arrives at a class with subclasses, it needs
 to be classified. Various methods may be employed to do so, one of these
-are the filters. All filters attached to the class are called, until one of 
-them returns with a verdict. If no verdict was made, other criteria may be 
+are the filters. All filters attached to the class are called, until one of
+them returns with a verdict. If no verdict was made, other criteria may be
 available. This differs per qdisc.
 
-It is important to notice that filters reside 
+It is important to notice that filters reside
 .B within
 qdiscs - they are not masters of what happens.
 
 .SH CLASSLESS QDISCS
 The classless qdiscs are:
-.TP 
+.TP
 [p|b]fifo
-Simplest usable qdisc, pure First In, First Out behaviour. Limited in 
+Simplest usable qdisc, pure First In, First Out behaviour. Limited in
 packets or in bytes.
 .TP
 pfifo_fast
 Standard qdisc for 'Advanced Router' enabled kernels. Consists of a three-band
-queue which honors Type of Service flags, as well as the priority that may be 
+queue which honors Type of Service flags, as well as the priority that may be
 assigned to a packet.
 .TP
 red
 Random Early Detection simulates physical congestion by randomly dropping
 packets when nearing configured bandwidth allocation. Well suited to very
 large bandwidth applications.
-.TP 
+.TP
 sfq
 Stochastic Fairness Queueing reorders queued traffic so each 'session'
 gets to send a packet in turn.
 .TP
 tbf
 The Token Bucket Filter is suited for slowing traffic down to a precisely
-configured rate. Scales well to large bandwidths. 
+configured rate. Scales well to large bandwidths.
 .SH CONFIGURING CLASSLESS QDISCS
-In the absence of classful qdiscs, classless qdiscs can only be attached at 
+In the absence of classful qdiscs, classless qdiscs can only be attached at
 the root of a device. Full syntax:
 .P
-.B tc qdisc add dev 
-DEV 
-.B root 
+.B tc qdisc add dev
+DEV
+.B root
 QDISC QDISC-PARAMETERS
 
 To remove, issue
@@ -164,7 +164,7 @@ To remove, issue
 DEV
 .B root
 
-The  
+The
 .B pfifo_fast
 qdisc is the automatic default in the absence of a configured qdisc.
 
@@ -172,85 +172,85 @@ qdisc is the automatic default in the absence of a configured qdisc.
 The classful qdiscs are:
 .TP
 CBQ
-Class Based Queueing implements a rich linksharing hierarchy of classes. 
+Class Based Queueing implements a rich linksharing hierarchy of classes.
 It contains shaping elements as well as prioritizing capabilities. Shaping is
 performed using link idle time calculations based on average packet size and
 underlying link bandwidth. The latter may be ill-defined for some interfaces.
 .TP
 HTB
-The Hierarchy Token Bucket implements a rich linksharing hierarchy of 
+The Hierarchy Token Bucket implements a rich linksharing hierarchy of
 classes with an emphasis on conforming to existing practices. HTB facilitates
 guaranteeing bandwidth to classes, while also allowing specification of upper
 limits to inter-class sharing. It contains shaping elements, based on TBF and
-can prioritize classes.	
-.TP 
+can prioritize classes.
+.TP
 PRIO
-The PRIO qdisc is a non-shaping container for a configurable number of 
-classes which are dequeued in order. This allows for easy prioritization 
-of traffic, where lower classes are only able to send if higher ones have 
-no packets available. To facilitate configuration, Type Of Service bits are 
+The PRIO qdisc is a non-shaping container for a configurable number of
+classes which are dequeued in order. This allows for easy prioritization
+of traffic, where lower classes are only able to send if higher ones have
+no packets available. To facilitate configuration, Type Of Service bits are
 honored by default.
 .SH THEORY OF OPERATION
-Classes form a tree, where each class has a single parent. 
+Classes form a tree, where each class has a single parent.
 A class may have multiple children. Some qdiscs allow for runtime addition
-of classes (CBQ, HTB) while others (PRIO) are created with a static number of 
+of classes (CBQ, HTB) while others (PRIO) are created with a static number of
 children.
 
-Qdiscs which allow dynamic addition of classes can have zero or more 
-subclasses to which traffic may be enqueued. 
+Qdiscs which allow dynamic addition of classes can have zero or more
+subclasses to which traffic may be enqueued.
 
 Furthermore, each class contains a
 .B leaf qdisc
-which by default has 
-.B pfifo 
-behaviour though another qdisc can be attached in place. This qdisc may again 
-contain classes, but each class can have only one leaf qdisc. 
+which by default has
+.B pfifo
+behaviour though another qdisc can be attached in place. This qdisc may again
+contain classes, but each class can have only one leaf qdisc.
 
-When a packet enters a classful qdisc it can be 
+When a packet enters a classful qdisc it can be
 .B classified
-to one of the classes within. Three criteria are available, although not all 
+to one of the classes within. Three criteria are available, although not all
 qdiscs will use all three:
-.TP 
+.TP
 tc filters
-If tc filters are attached to a class, they are consulted first 
-for relevant instructions. Filters can match on all fields of a packet header, 
-as well as on the firewall mark applied by ipchains or iptables. 
+If tc filters are attached to a class, they are consulted first
+for relevant instructions. Filters can match on all fields of a packet header,
+as well as on the firewall mark applied by ipchains or iptables.
 .TP
 Type of Service
 Some qdiscs have built in rules for classifying packets based on the TOS field.
 .TP
 skb->priority
-Userspace programs can encode a class-id in the 'skb->priority' field using 
+Userspace programs can encode a class-id in the 'skb->priority' field using
 the SO_PRIORITY option.
 .P
 Each node within the tree can have its own filters but higher level filters
 may also point directly to lower classes.
 
-If classification did not succeed, packets are enqueued to the leaf qdisc 
+If classification did not succeed, packets are enqueued to the leaf qdisc
 attached to that class. Check qdisc specific manpages for details, however.
 
 .SH NAMING
 All qdiscs, classes and filters have IDs, which can either be specified
-or be automatically assigned. 
+or be automatically assigned.
 
 IDs consist of a major number and a minor number, separated by a colon.
 
-.TP 
+.TP
 QDISCS
-A qdisc, which potentially can have children, 
-gets assigned a major number, called a 'handle', leaving the minor 
-number namespace available for classes. The handle is expressed as '10:'. 
-It is customary to explicitly assign a handle to qdiscs expected to have 
+A qdisc, which potentially can have children,
+gets assigned a major number, called a 'handle', leaving the minor
+number namespace available for classes. The handle is expressed as '10:'.
+It is customary to explicitly assign a handle to qdiscs expected to have
 children.
 
-.TP 
+.TP
 CLASSES
 Classes residing under a qdisc share their qdisc major number, but each have
-a separate minor number called a 'classid' that has no relation to their 
-parent classes, only to their parent qdisc. The same naming custom as for 
+a separate minor number called a 'classid' that has no relation to their
+parent classes, only to their parent qdisc. The same naming custom as for
 qdiscs applies.
 
-.TP 
+.TP
 FILTERS
 Filters have a three part ID, which is only needed when using a hashed
 filter hierarchy.
@@ -258,7 +258,7 @@ filter hierarchy.
 All parameters accept a floating point number, possibly followed by a unit.
 .P
 Bandwidths or rates can be specified in:
-.TP 
+.TP
 kbps
 Kilobytes per second
 .TP
@@ -306,9 +306,9 @@ Microseconds.
 The following commands are available for qdiscs, classes and filter:
 .TP
 add
-Add a qdisc, class or filter to a node. For all entities, a 
+Add a qdisc, class or filter to a node. For all entities, a
 .B parent
-must be passed, either by passing its ID or by attaching directly to the root of a device. 
+must be passed, either by passing its ID or by attaching directly to the root of a device.
 When creating a qdisc or a filter, it can be named with the
 .B handle
 parameter. A class is named with the
@@ -317,15 +317,15 @@ parameter.
 
 .TP
 remove
-A qdisc can be removed by specifying its handle, which may also be 'root'. All subclasses and their leaf qdiscs 
+A qdisc can be removed by specifying its handle, which may also be 'root'. All subclasses and their leaf qdiscs
 are automatically deleted, as well as any filters attached to them.
 
 .TP
 change
 Some entities can be modified 'in place'. Shares the syntax of 'add', with the exception
-that the handle cannot be changed and neither can the parent. In other words, 
+that the handle cannot be changed and neither can the parent. In other words,
 .B
-change 
+change
 cannot move a node.
 
 .TP
@@ -335,7 +335,7 @@ it is created.
 
 .TP
 link
-Only available for qdiscs and performs a replace where the node 
+Only available for qdiscs and performs a replace where the node
 must exist already.
 
 .SH FORMAT
-- 
1.7.10
