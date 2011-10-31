From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH] [PATCH] HFSC (7) & (8) doc... (fixups)
Date: Mon, 31 Oct 2011 22:56:38 +0100
Message-ID: <1320098198-14642-1-git-send-email-soltys@ziu.info>
References: <4EAF1904.8060307@ziu.info>
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:42476 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020Ab1JaV4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Oct 2011 17:56:55 -0400
In-Reply-To: <4EAF1904.8060307@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few minore changes and small additions.
---
 man/man7/tc-hfsc.7 |   94 ++++++++++++++++++++++++++++++++++++----------------
 man/man8/tc-hfsc.8 |    2 +-
 man/man8/tc-stab.8 |   49 +++++++++++++++-----------
 3 files changed, 94 insertions(+), 51 deletions(-)

diff --git a/man/man7/tc-hfsc.7 b/man/man7/tc-hfsc.7
index bcdea7b..9a9d85a 100644
--- a/man/man7/tc-hfsc.7
+++ b/man/man7/tc-hfsc.7
@@ -1,4 +1,4 @@
-.TH HFSC 7 "25 February 2009" iproute2 Linux
+.TH HFSC 7 "31 October 2011" iproute2 Linux
 .ce 1
 \fBHIERARCHICAL FAIR SERVICE CURVE\fR
 .
@@ -158,7 +158,7 @@ curve.
 .IP "V()"
 In linkshare criterion, arbitrates which packet to send next. Note that V() is
 function of a virtual time \- see \fBLINKSHARE CRITERION\fR section for
-details.  Virtual time \&'vt' corresponds to packets' heads
+details. Virtual time \&'vt' corresponds to packets' heads
 (vt\~=\~V^(\-1)(w)). Based on LS service curve.
 .IP "F()"
 An extension to linkshare criterion, used to limit at which speed linkshare
@@ -187,12 +187,12 @@ Interface 10mbit, two classes, both with two\-piece linear service curves:
 .PP
 Assume for a moment, that we only use D() for both finding eligible packets,
 and choosing the most fitting one, thus eligible time would be computed as
-D^(\-1)(w) and deadline time would be computed as D^(\-1)(w+l).  If the 2nd
+D^(\-1)(w) and deadline time would be computed as D^(\-1)(w+l). If the 2nd
 class starts sending packets 1 second after the 1st class, it's of course
 impossible to guarantee 14mbit, as the interface capability is only 10mbit.
 The only workaround in this scenario is to allow the 1st class to send the
 packets earlier that would normally be allowed. That's where separate E() comes
-to help.  Putting all the math aside (see HFSC paper for details), E() for RT
+to help. Putting all the math aside (see HFSC paper for details), E() for RT
 concave service curve is just like D(), but for the RT convex service curve \-
 it's constructed using \fIonly\fR RT service curve's 2nd slope (in our example
 \- 7mbit).
@@ -255,7 +255,7 @@ Such approach has its price though. The problem is analogous to what was
 presented in previous section and is caused by non\-linearity of service
 curves:
 .IP 1) 4
-either it's impossible to guarantee both service curves and satisfy fairness
+either it's impossible to guarantee service curves and satisfy fairness
 during certain time periods:
 
 .RS 4
@@ -278,40 +278,40 @@ beyond of what the interface is capable of.
 .RE
 
 .IP 2) 4
-and/or it's impossible to guarantee service curves of all classes at all
+and/or it's impossible to guarantee service curves of all classes at the same
+time [fairly or not]:
 
 .RS 4
-Even if we didn't use virtual time and allowed a session to be "punished",
-there's a possibility that service curves of all classes couldn't be
-guaranteed for a brief period. Consider following, a bit more complicated
-example:
-
-Root interface, classes A and B with concave and convex curve (summing up to
-root), A1 & A2 (children of A), \fIboth\fR with concave curves summing up to A,
-B1 & B2 (children of B), \fIboth\fR with convex curves summing up to B.
 
-Assume that A2, B1 and B2 are constantly backlogged, and at some later point
-A1 becomes backlogged. We can easily choose slopes, so that even if we
-"punish" A2 for earlier excess bandwidth received, A1 will have no chance of
-getting bandwidth corresponding to its first slope. Following from the above
-example:
+This is similar to the above case, but a bit more subtle. We will consider two
+subtrees, arbitrated by their common (root here) parent:
 
 .nf
+R (root) -\ 10mbit
+
 A  \- 7mbit, then 3mbit
 A1 \- 5mbit, then 2mbit
 A2 \- 2mbit, then 1mbit
 
 B  \- 3mbit, then 7mbit
-B1 \- 2mbit, then 5mbit
-B2 \- 1mbit, then 2mbit
 .fi
 
-At the point when A1 starts sending, it should get 5mbit to not violate its
-service curve. A2 gets punished and doesn't send at all, B1 and B2 both keep
-sending at their 5mbit and 2mbit. But as you can see, we already are beyond
-interface's capacity \- at 12mbit. A1 could get 3mbit at most. If we used
-virtual times and kept fairness property, A1 and A2 would send at 3mbit
-together with 5:2 ratio (so respectively at ~2.14mbit and ~0.86mbit).
+R arbitrates between left subtree (A) and right (B). Assume that A2 and B are
+constantly backlogged, and at some later point A1 becomes backlogged (when all
+other classes are in their 2nd linear part).
+
+What happens now ? B (choice made by R) will \fIalways\fR get 7 mbit as R is
+only (obviously) concerned with the ratio between its direct children. Thus A
+subtree gets 3mbit, but its children would want (at the point when A1 became
+backlogged) 5mbit + 1mbit. That's of course impossible, as they can only get
+3mbit due to interface limitation.
+
+In the left subtree \- we have the same situation as previously (fair split
+between A1 and A2, but violated guarantees), but in the whole tree \- there's
+no fairness (B got 7mbit, but A1 and A2 have to fit together in 3mbit) and
+there's no guarantees for all classes (only B got what it wanted). Even if we
+violated fairness in the A subtree and set A2's service curve to 0, A1 would
+still not get the required bandwidth.
 .RE
 .
 .SH "UPPERLIMIT CRITERION"
@@ -416,6 +416,19 @@ In the other words - LS criterion is meaningless in the above example.
 You can quickly "workaround" it by making sure each leaf class has RT service
 curve assigned (thus guaranteeing all of them will get some bandwidth), but it
 doesn't make it any more valid.
+
+Keep in mind - if you use nonlinear curves and irregularities explained above
+happen \fIonly\fR in the first segment, then there's little wrong with
+"overusing" RT curve a bit:
+
+.nf
+A \- ls 5.0mbit, rt 9mbit/30ms, then 1mbit
+B \- ls 2.5mbit
+C \- ls 2.5mbit
+.fi
+
+Here, the vt of A will "spike" in the initial period, but then A will never get more
+than 1mbit, until B & C catch up. Then everything will be back to normal.
 .
 .SH "LINUX AND TIMER RESOLUTION"
 .
@@ -434,7 +447,7 @@ If you have \&'tickless system' enabled, then the timer interrupt will trigger
 as slowly as possible, but each time a scheduler throttles itself (or any
 other part of the kernel needs better accuracy), the rate will be increased as
 needed / possible. The ceiling is either \&'timer frequency' if \&'high
-resolution timer support' is not available or not compiled in. Otherwise it's
+resolution timer support' is not available or not compiled in, or it's
 hardware dependent and can go \fIfar\fR beyond the highest \&'timer frequency'
 setting available.
 
@@ -458,7 +471,7 @@ tc class add dev eth0 parent 1:0 classid 1:1 hfsc rt m2 10mbit
 
 Assuming packet of ~1KB size and HZ=100, that averages to ~0.8mbit \- anything
 beyond it (e.g. the above example with specified rate over 10x bigger) will
-require appropriate queuing and cause bursts every ~10 ms.  As you can
+require appropriate queuing and cause bursts every ~10 ms. As you can
 imagine, any HFSC's RT guarantees will be seriously invalidated by that.
 Aforementioned example is mainly important if you deal with old hardware \- as
 it's particularly popular for home server chores. Even then, you can easily
@@ -510,6 +523,29 @@ curve there, and in such scenario HFSC simply doesn't throttle at all.
 So, in rare case you need those speeds with only RT service curve, or with UL
 service curve \- remember about drawbacks.
 .
+.SH "CAVEAT: RANDOM ONLINE EXAMPLES"
+.
+For reasons unknown (though well guessed), many examples you can google love to
+overuse UL criterion and stuff it in every node possible. This makes no sense
+and works against what HFSC tries to do (and does pretty damn well). Use UL
+where it makes sense - on the uppermost node to match upstream router's uplink
+capacity. Or - in special cases, such as testing (limit certain subtree to some
+speed) or customers that must never get more than certain speed. In the last
+case you can usually achieve the same by just using RT criterion without LS+UL
+on leaf nodes.
+
+As for router case - remember it's good to differentiate between "traffic to
+router" (remote console, web config, etc.) and "outgoing traffic", so for
+example:
+
+.nf
+tc qdisc add dev eth0 root handle 1:0 hfsc default 0x8002
+tc class add dev eth0 parent 1:0 classid 1:999 hfsc rt m2 50mbit
+tc class add dev eth0 parent 1:0 classid 1:1 hfsc ls m2 2mbit ul m2 2mbit
+.fi
+
+\&... so "internet" tree under 1:1 and "router itself" as 1:999
+.
 .SH "LAYER2 ADAPTATION"
 .
 Please refer to \fBtc\-stab\fR(8)
diff --git a/man/man8/tc-hfsc.8 b/man/man8/tc-hfsc.8
index 22018c0..c5ff331 100644
--- a/man/man8/tc-hfsc.8
+++ b/man/man8/tc-hfsc.8
@@ -1,4 +1,4 @@
-.TH HFSC 8 "25 February 2009" iproute2 Linux
+.TH HFSC 8 "31 October 2011" iproute2 Linux
 .
 .SH NAME
 HFSC \- Hierarchical Fair Service Curve's control under linux
diff --git a/man/man8/tc-stab.8 b/man/man8/tc-stab.8
index 1442a69..522ea00 100644
--- a/man/man8/tc-stab.8
+++ b/man/man8/tc-stab.8
@@ -1,4 +1,4 @@
-.TH STAB 8 "25 February 2009" iproute2 Linux
+.TH STAB 8 "31 October 2011" iproute2 Linux
 .
 .SH NAME
 tc\-stab \- Generic size table manipulations
@@ -42,14 +42,14 @@ size is calculated only once \- when a qdisc enqueues the packet. Initial root
 enqueue initializes it to the real packet's size.
 
 Each qdisc can use different size table, but the adjusted size is stored in
-area shared by whole qdisc hierarchy attached to the interface (technically,
-it's stored in skb). The effect is, that if you have such setup, the last qdisc
-with a stab in a chain "wins". For example, consider HFSC with simple pfifo
-attached to one of its leaf classes. If that pfifo qdisc has stab defined, it
-will override lengths calculated during HFSC's enqueue, and in turn, whenever
-HFSC tries to dequeue a packet, it will use potentially invalid size in its
-calculations. Normal setups will usually include stab defined only on root
-qdisc, but further overriding gives extra flexibility for less usual setups.
+area shared by whole qdisc hierarchy attached to the interface. The effect is,
+that if you have such setup, the last qdisc with a stab in a chain "wins". For
+example, consider HFSC with simple pfifo attached to one of its leaf classes.
+If that pfifo qdisc has stab defined, it will override lengths calculated
+during HFSC's enqueue, and in turn, whenever HFSC tries to dequeue a packet, it
+will use potentially invalid size in its calculations. Normal setups will
+usually include stab defined only on root qdisc, but further overriding gives
+extra flexibility for less usual setups.
 
 Initial size table is calculated by \fBtc\fR tool using \fBmtu\fR and
 \fBtsize\fR parameters. The algorithm sets each slot's size to the smallest
@@ -59,18 +59,16 @@ table will usually support more than is required by \fBmtu\fR.
 
 For example, with \fBmtu\fR\~=\~1500 and \fBtsize\fR\~=\~128, a table with 128
 slots will be created, where slot 0 will correspond to sizes 0\-16, slot 1 to
-17\~\-\~32, \&..., slot 127 to 2033\~\-\~2048. Note, that the sizes
-are shifted 1 byte (normally you would expect 0\~\-\~15, 16\~\-\~31, \&...,
-2032\~\-\~2047). Sizes assigned to each slot depend on \fBlinklayer\fR parameter.
+17\~\-\~32, \&..., slot 127 to 2033\~\-\~2048. Sizes assigned to each slot
+depend on \fBlinklayer\fR parameter.
 
 Stab calculation is also safe for an unusual case, when a size assigned to a
 slot would be larger than 2^16\-1 (you will lose the accuracy though).
 
 During kernel part of packet size adjustment, \fBoverhead\fR will be added to
-original size, and after subtracting 1 (to land in the proper slot \- see above
-about shifting by 1 byte) slot will be calculated. If the size would cause
-overflow, more than 1 slot will be used to get the final size. It of course will
-affect accuracy, but it's only a guard against unusual situations.
+original size, and then slot will be calculated. If the size would cause
+overflow, more than 1 slot will be used to get the final size. It of course
+will affect accuracy, but it's only a guard against unusual situations.
 
 Currently there're two methods of creating values stored in the size table \-
 ethernet and atm (adsl):
@@ -82,8 +80,8 @@ This is basically 1\-1 mapping, so following our example from above
 and so on, up to slot 127 with 2048. Note, that \fBmpu\fR\~>\~0 must be
 specified, and slots that would get less than specified by \fBmpu\fR, will get
 \fBmpu\fR instead. If you don't specify \fBmpu\fR, the size table will not be
-created at all, although any \fBoverhead\fR value will be respected during
-calculations.
+created at all (it wouldn't make any difference), although any \fBoverhead\fR
+value will be respected during calculations.
 .IP "atm, adsl"
 .br
 ATM linklayer consists of 53 byte cells, where each of them provides 48 bytes
@@ -127,7 +125,7 @@ IPoA in LLC case requires SNAP, instead of LLC\-NLPID (see rfc2684) \- this is
 the reason, why it actually takes more space than PPPoA.
 .IP \(bu
 In rare cases, FCS might be preserved on protocols that include ethernet frame
-(Bridged and PPPoE).  In such situation, any ethernet specific padding
+(Bridged and PPPoE). In such situation, any ethernet specific padding
 guaranteeing 64 bytes long frame size has to be included as well (see rfc2684).
 In the other words, it also guarantees that any packet you send will take
 minimum 2 atm cells. You should set \fBmpu\fR accordingly for that.
@@ -136,11 +134,20 @@ When size table is consulted, and you're shaping traffic for the sake of
 another modem/router, ethernet header (without padding) will already be added
 to initial packet's length. You should compensate for that by subtracting 14
 from the above overheads in such case. If you're shaping directly on the router
-(for example, with speedtouch usb modem) using ppp daemon, layer2 header will
-not be added yet.
+(for example, with speedtouch usb modem) using ppp daemon, you're using raw ip
+interface without underlying layer2, so nothing will be added.
 
 For more thorough explanations, please see \fB[1]\fR and \fB[2]\fR.
 .
+.SH "ETHERNET CARDS CONSIDERATIONS"
+.
+It's often forgotten, that modern network cards (even cheap ones on desktop
+motherboards) and/or their drivers often support different offloading
+mechanisms. In context of traffic shaping, 'tso' and 'gso' might cause
+undesirable effects, due to massive tcp segments being considered during
+traffic shaping (including stab calculations). For slow uplink interfaces,
+it's good to use \fBethtool\fR to turn off offloading features.
+.
 .SH "SEE ALSO"
 .
 \fBtc\fR(8), \fBtc\-hfsc\fR(7), \fBtc\-hfsc\fR(8),
-- 
1.7.7.1
