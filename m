From: Kees van Reeuwijk <kees.van.reeuwijk@gmail.com>
Subject: [PATCH v2 3/5] iproute2: clarifications in the tc-hfsc.7 man page
Date: Mon, 11 Feb 2013 17:11:13 +0100
Message-ID: <E1U4vyL-0003Wi-Me@babylon.few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f195.google.com ([209.85.212.195]:47405 "EHLO
	mail-wi0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757839Ab3BKQNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 11:13:22 -0500
Received: by mail-wi0-f195.google.com with SMTP id l13so1047132wie.2
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 08:13:20 -0800 (PST)
Received: from reeuwijk by babylon.few.vu.nl with local (Exim 4.72)
	(envelope-from <reeuwijk@few.vu.nl>)
	id 1U4vyL-0003Wi-Me
	for netdev@vger.kernel.org; Mon, 11 Feb 2013 17:11:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Improved man page as follows:
- Use more `mainstream' english
- Rephrased for clarity
- Use standard notation for units



Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---


 tc-hfsc.7 |  247 +++++++++++++++++++++++++++++++------------------------------
 1 files changed, 124 insertions(+), 123 deletions(-)

diff --git a/man/man7/tc-hfsc.7 b/man/man7/tc-hfsc.7
index d4e63f2..ca04961 100644
--- a/man/man7/tc-hfsc.7
+++ b/man/man7/tc-hfsc.7
@@ -4,13 +4,12 @@ tc-hfcs \- Hierarchical Fair Service Curve
 .
 .SH "HISTORY & INTRODUCTION"
 .
-HFSC \- \fBHierarchical Fair Service Curve\fR was first presented at
+HFSC (Hierarchical Fair Service Curve) is a network packet scheduling algorithm that was first presented at
 SIGCOMM'97. Developed as a part of ALTQ (ALTernative Queuing) on NetBSD, found
 its way quickly to other BSD systems, and then a few years ago became part of
 the linux kernel. Still, it's not the most popular scheduling algorithm \-
-especially if compared to HTB \- and it's not well documented from enduser's
-perspective. This introduction aims to explain how HFSC works without
-going to deep into math side of things (although some if it will be
+especially if compared to HTB \- and it's not well documented for the enduser. This introduction aims to explain how HFSC works without using
+too much math (although some math it will be
 inevitable).
 
 In short HFSC aims to:
@@ -30,10 +29,10 @@ service provided during linksharing
 .
 The main "selling" point of HFSC is feature \fB(1)\fR, which is achieved by
 using nonlinear service curves (more about what it actually is later). This is
-particularly useful in VoIP or games, where not only guarantee of consistent
-bandwidth is important, but initial delay of a data stream as well. Note that
+particularly useful in VoIP or games, where not only a guarantee of consistent
+bandwidth is important, but also limiting the initial delay of a data stream. Note that
 it matters only for leaf classes (where the actual queues are) \- thus class
-hierarchy is ignored in realtime case.
+hierarchy is ignored in the realtime case.
 
 Feature \fB(2)\fR is well, obvious \- any algorithm featuring class hierarchy
 (such as HTB or CBQ) strives to achieve that. HFSC does that well, although
@@ -44,8 +43,8 @@ Feature \fB(3)\fR is mentioned due to the nature of the problem. There may be
 situations where it's either not possible to guarantee service of all curves at
 the same time, and/or it's impossible to do so fairly. Both will be explained
 later. Note that this is mainly related to interior (aka aggregate) classes, as
-the leafs are already handled by \fB(1)\fR. Still \- it's perfectly possible to
-create a leaf class w/o realtime service, and in such case \- the caveats will
+the leafs are already handled by \fB(1)\fR. Still, it's perfectly possible to
+create a leaf class without realtime service, and in such a case the caveats will
 naturally extend to leaf classes as well.
 
 .SH ABBREVIATIONS
@@ -62,21 +61,22 @@ SC \- service curve
 .SH "BASICS OF HFSC"
 .
 To understand how HFSC works, we must first introduce a service curve.
-Overall, it's a nondecreasing function of some time unit, returning amount of
-service (allowed or allocated amount of bandwidth) by some specific point in
-time. The purpose of it should be subconsciously obvious \- if a class was
-allowed to transfer not less than the amount specified by its service curve \-
-then service curve is not violated.
-
-Still \- we need more elaborate criterion than just the above (although in
-most generic case it can be reduced to it). The criterion has to take two
+Overall, it's a nondecreasing function of some time unit, returning the amount
+of
+service (an allowed or allocated amount of bandwidth) at some specific point in
+time. The purpose of it should be subconsciously obvious: if a class was
+allowed to transfer not less than the amount specified by its service curve,
+then the service curve is not violated.
+
+Still, we need more elaborate criterion than just the above (although in
+the most generic case it can be reduced to it). The criterion has to take two
 things into account:
 .
 .RS 4
 .IP \(bu 4
 idling periods
 .IP \(bu
-ability to "look back", so if during current active period service curve is violated, maybe it
+the ability to "look back", so if during current active period the service curve is violated, maybe it
 isn't if we count excess bandwidth received during earlier active period(s)
 .RE
 .PP
@@ -102,9 +102,9 @@ as in (a), but with a larger gap
 .RE
 .
 .PP
-Consider \fB(a)\fR \- if the service received during both periods meets
-\fB(1)\fR, then all is good. But what if it doesn't do so during the 2nd
-period ? If the amount of service received during the 1st period is bigger
+Consider \fB(a)\fR: if the service received during both periods meets
+\fB(1)\fR, then all is well. But what if it doesn't do so during the 2nd
+period? If the amount of service received during the 1st period is larger
 than the service curve, then it might compensate for smaller service during
 the 2nd period \fIand\fR the gap \- if the gap is small enough.
 
@@ -172,42 +172,43 @@ curves and the above "utility" functions.
 .SH "REALTIME CRITERION"
 .
 RT criterion \fIignores class hierarchy\fR and guarantees precise bandwidth and
-delay allocation. We say that packet is eligible for sending, when current real
-time is bigger than eligible time. From all packets eligible, the one most
-suited for sending, is the one with the smallest deadline time. Sounds simply,
-but consider following example:
+delay allocation. We say that a packet is eligible for sending, when the
+current real
+time is later than the eligible time of the packet. From all eligible packets, the one most
+suited for sending is the one with the shortest deadline time. This sounds
+simple, but consider the following example:
 
-Interface 10mbit, two classes, both with two\-piece linear service curves:
+Interface 10Mbit, two classes, both with two\-piece linear service curves:
 .RS 4
 .IP \(bu 4
-1st class \- 2mbit for 100ms, then 7mbit (convex \- 1st slope < 2nd slope)
+1st class \- 2Mbit for 100ms, then 7Mbit (convex \- 1st slope < 2nd slope)
 .IP \(bu
-2nd class \- 7mbit for 100ms, then 2mbit (concave \- 1st slope > 2nd slope)
+2nd class \- 7Mbit for 100ms, then 2Mbit (concave \- 1st slope > 2nd slope)
 .RE
 .PP
 Assume for a moment, that we only use D() for both finding eligible packets,
 and choosing the most fitting one, thus eligible time would be computed as
 D^(\-1)(w) and deadline time would be computed as D^(\-1)(w+l). If the 2nd
 class starts sending packets 1 second after the 1st class, it's of course
-impossible to guarantee 14mbit, as the interface capability is only 10mbit.
+impossible to guarantee 14Mbit, as the interface capability is only 10Mbit.
 The only workaround in this scenario is to allow the 1st class to send the
 packets earlier that would normally be allowed. That's where separate E() comes
 to help. Putting all the math aside (see HFSC paper for details), E() for RT
 concave service curve is just like D(), but for the RT convex service curve \-
 it's constructed using \fIonly\fR RT service curve's 2nd slope (in our example
-\- 7mbit).
+ 7Mbit).
 
 The effect of such E() \- packets will be sent earlier, and at the same time
-D() \fIwill\fR be updated \- so current deadline time calculated from it will
-be bigger. Thus, when the 2nd class starts sending packets later, both the 1st
-and the 2nd class will be eligible, but the 2nd session's deadline time will be
-smaller and its packets will be sent first. When the 1st class becomes idle at
-some later point, the 2nd class will be able to "buffer" up again for later
-active period of the 1st class.
+D() \fIwill\fR be updated \- so the current deadline time calculated from it
+will be later. Thus, when the 2nd class starts sending packets later, both
+the 1st and the 2nd class will be eligible, but the 2nd session's deadline
+time will be smaller and its packets will be sent first. When the 1st class
+becomes idle at some later point, the 2nd class will be able to "buffer" up
+again for later active period of the 1st class.
 
 A short remark \- in a situation, where the total amount of bandwidth
-available on the interface is bigger than the allocated total realtime parts
-(imagine interface 10 mbit, but 1mbit/2mbit and 2mbit/1mbit classes), the sole
+available on the interface is larger than the allocated total realtime parts
+(imagine a 10 Mbit interface, but 1Mbit/2Mbit and 2Mbit/1Mbit classes), the sole
 speed of the interface could suffice to guarantee the times.
 
 Important part of RT criterion is that apart from updating its D() and E(),
@@ -233,18 +234,18 @@ real time and virtual time \- the decision is based solely on direct comparison
 of virtual times of all active subclasses \- the one with the smallest vt wins
 and gets scheduled. One immediate conclusion from this fact is that absolute
 values don't matter \- only ratios between them (so for example, two children
-classes with simple linear 1mbit service curves will get the same treatment
-from LS criterion's perspective, as if they were 5mbit). The other conclusion
+classes with simple linear 1Mbit service curves will get the same treatment
+from LS criterion's perspective, as if they were 5Mbit). The other conclusion
 is, that in perfectly fluid system with linear curves, all virtual times across
 whole class hierarchy would be equal.
 
-Why is VC defined in term of virtual time (and what is it) ?
+Why is VC defined in term of virtual time (and what is it)?
 
 Imagine an example: class A with two children \- A1 and A2, both with let's say
-10mbit SCs. If A2 is idle, A1 receives all the bandwidth of A (and update its
+10Mbit SCs. If A2 is idle, A1 receives all the bandwidth of A (and update its
 V() in the process). When A2 becomes active, A1's virtual time is already
-\fIfar\fR bigger than A2's one. Considering the type of decision made by LS
-criterion, A1 would become idle for a lot of time. We can workaround this
+\fIfar\fR later than A2's one. Considering the type of decision made by LS
+criterion, A1 would become idle for a long time. We can workaround this
 situation by adjusting virtual time of the class becoming active \- we do that
 by getting such time "up to date". HFSC uses a mean of the smallest and the
 biggest virtual time of currently active children fit for sending. As it's not
@@ -259,20 +260,20 @@ either it's impossible to guarantee service curves and satisfy fairness
 during certain time periods:
 
 .RS 4
-Recall the example from RT section, slightly modified (with 3mbit slopes
-instead of 2mbit ones):
+Recall the example from RT section, slightly modified (with 3Mbit slopes
+instead of 2Mbit ones):
 
 .IP \(bu 4
-1st class \- 3mbit for 100ms, then 7mbit (convex \- 1st slope < 2nd slope)
+1st class \- 3Mbit for 100ms, then 7Mbit (convex \- 1st slope < 2nd slope)
 .IP \(bu
-2nd class \- 7mbit for 100ms, then 3mbit (concave \- 1st slope > 2nd slope)
+2nd class \- 7Mbit for 100ms, then 3Mbit (concave \- 1st slope > 2nd slope)
 
 .PP
-They sum up nicely to 10mbit \- interface's capacity. But if we wanted to only
+They sum up nicely to 10Mbit \- the interface's capacity. But if we wanted to only
 use LS for guarantees and fairness \- it simply won't work. In LS context,
 only V() is used for making decision which class to schedule. If the 2nd class
 becomes active when the 1st one is in its second slope, the fairness will be
-preserved \- ratio will be 1:1 (7mbit:7mbit), but LS itself is of course
+preserved \- ratio will be 1:1 (7Mbit:7Mbit), but LS itself is of course
 unable to guarantee the absolute values themselves \- as it would have to go
 beyond of what the interface is capable of.
 .RE
@@ -287,28 +288,28 @@ This is similar to the above case, but a bit more subtle. We will consider two
 subtrees, arbitrated by their common (root here) parent:
 
 .nf
-R (root) -\ 10mbit
+R (root) -\ 10Mbit
 
-A  \- 7mbit, then 3mbit
-A1 \- 5mbit, then 2mbit
-A2 \- 2mbit, then 1mbit
+A  \- 7Mbit, then 3Mbit
+A1 \- 5Mbit, then 2Mbit
+A2 \- 2Mbit, then 1Mbit
 
-B  \- 3mbit, then 7mbit
+B  \- 3Mbit, then 7Mbit
 .fi
 
 R arbitrates between left subtree (A) and right (B). Assume that A2 and B are
 constantly backlogged, and at some later point A1 becomes backlogged (when all
 other classes are in their 2nd linear part).
 
-What happens now ? B (choice made by R) will \fIalways\fR get 7 mbit as R is
+What happens now? B (choice made by R) will \fIalways\fR get 7 Mbit as R is
 only (obviously) concerned with the ratio between its direct children. Thus A
-subtree gets 3mbit, but its children would want (at the point when A1 became
-backlogged) 5mbit + 1mbit. That's of course impossible, as they can only get
-3mbit due to interface limitation.
+subtree gets 3Mbit, but its children would want (at the point when A1 became
+backlogged) 5Mbit + 1Mbit. That's of course impossible, as they can only get
+3Mbit due to interface limitation.
 
 In the left subtree \- we have the same situation as previously (fair split
 between A1 and A2, but violated guarantees), but in the whole tree \- there's
-no fairness (B got 7mbit, but A1 and A2 have to fit together in 3mbit) and
+no fairness (B got 7Mbit, but A1 and A2 have to fit together in 3Mbit) and
 there's no guarantees for all classes (only B got what it wanted). Even if we
 violated fairness in the A subtree and set A2's service curve to 0, A1 would
 still not get the required bandwidth.
@@ -317,83 +318,83 @@ still not get the required bandwidth.
 .SH "UPPERLIMIT CRITERION"
 .
 UL criterion is an extensions to LS one, that permits sending packets only
-if current real time is bigger than fit\-time ('ft'). So the modified LS
+if current real time is later than fit\-time ('ft'). So the modified LS
 criterion becomes: choose the smallest virtual time from all active children,
 such that fit\-time < current real time also holds. Fit\-time is calculated
 from F(), which is based on UL service curve. As you can see, its role is
 kinda similar to E() used in RT criterion. Also, for obvious reasons \- you
 can't specify UL service curve without LS one.
 
-Main purpose of UL service curve is to limit HFSC to bandwidth available on the
+The main purpose of the UL service curve is to limit HFSC to bandwidth available on the
 upstream router (think adsl home modem/router, and linux server as
-nat/firewall/etc. with 100mbit+ connection to mentioned modem/router).
+NAT/firewall/etc. with 100Mbit+ connection to mentioned modem/router).
 Typically, it's used to create a single class directly under root, setting
-linear UL service curve to available bandwidth \- and then creating your class
-structure from that class downwards. Of course, you're free to add UL service
-(linear or not) curve to any class with LS criterion.
+a linear UL service curve to available bandwidth \- and then creating your class
+structure from that class downwards. Of course, you're free to add a UL service
+curve (linear or not) to any class with LS criterion.
 
-Important part about UL service curve is, that whenever at some point in time
+An important part about the UL service curve is that whenever at some point in time
 a class doesn't qualify for linksharing due to its fit\-time, the next time it
-does qualify, it will update its virtual time to the smallest virtual time of
-all active children fit for linksharing. This way, one of the main things LS
+does qualify it will update its virtual time to the smallest virtual time of
+all active children fit for linksharing. This way, one of the main things the LS
 criterion tries to achieve \- equality of all virtual times across whole
 hierarchy \- is preserved (in perfectly fluid system with only linear curves,
 all virtual times would be equal).
 
 Without that, 'vt' would lag behind other virtual times, and could cause
-problems. Consider interface with capacity 10mbit, and following leaf classes
+problems. Consider an interface with a capacity of 10Mbit, and the following leaf classes
 (just in case you're skipping this text quickly \- this example shows behavior
 that \f(BIdoesn't happen\fR):
 
 .nf
-A \- ls 5.0mbit
-B \- ls 2.5mbit
-C \- ls 2.5mbit, ul 2.5mbit
+A \- ls 5.0Mbit
+B \- ls 2.5Mbit
+C \- ls 2.5Mbit, ul 2.5Mbit
 .fi
 
-If B was idle, while A and C were constantly backlogged, they would normally
+If B was idle, while A and C were constantly backlogged, A and C would normally
 (as far as LS criterion is concerned) divide bandwidth in 2:1 ratio. But due
-to UL service curve in place, C would get at most 2.5mbit, and A would get the
-remaining 7.5mbit. The longer the backlogged period, the more virtual times of
+to UL service curve in place, C would get at most 2.5Mbit, and A would get the
+remaining 7.5Mbit. The longer the backlogged period, the more the virtual times of
 A and C would drift apart. If B became backlogged at some later point in time,
 its virtual time would be set to (A's\~vt\~+\~C's\~vt)/2, thus blocking A from
-sending any traffic, until B's virtual time catches up with A.
+sending any traffic until B's virtual time catches up with A.
 .
 .SH "SEPARATE LS / RT SCs"
 .
-Another difference from original HFSC paper, is that RT and LS SCs can be
-specified separately. Moreover \- leaf classes are allowed to have only either
-RT SC or LS SC. For interior classes, only LS SCs make sense \- Any RT SC will
+Another difference from the original HFSC paper is that RT and LS SCs can be
+specified separately. Moreover, leaf classes are allowed to have only either
+RT SC or LS SC. For interior classes, only LS SCs make sense: any RT SC will
 be ignored.
 .
 .SH "CORNER CASES"
 .
-Separate service curves for LS and RT criteria can lead to certain traps,
+Separate service curves for LS and RT criteria can lead to certain traps
 that come from "fighting" between ideal linksharing and enforced realtime
 guarantees. Those situations didn't exist in original HFSC paper, where
 specifying separate LS / RT service curves was not discussed.
 
-Consider interface with capacity 10mbit, with following leaf classes:
+Consider an interface with a 10Mbit capacity, with the following leaf classes:
 
 .nf
-A \- ls 5.0mbit, rt 8mbit
-B \- ls 2.5mbit
-C \- ls 2.5mbit
+A \- ls 5.0Mbit, rt 8Mbit
+B \- ls 2.5Mbit
+C \- ls 2.5Mbit
 .fi
 
 Imagine A and C are constantly backlogged. As B is idle, A and C would divide
 bandwidth in 2:1 ratio, considering LS service curve (so in theory \- 6.66 and
-3.33). Alas RT criterion takes priority, so A will get 8mbit and LS will be
-able to compensate class C for only 2 mbit \- this will cause discrepancy
+3.33). Alas RT criterion takes priority, so A will get 8Mbit and LS will be
+able to compensate class C for only 2 Mbit \- this will cause discrepancy
 between virtual times of A and C.
 
-Assume this situation lasts for a lot of time with no idle periods, and
+Assume this situation lasts for a long time with no idle periods, and
 suddenly B becomes active. B's virtual time will be updated to
 (A's\~vt\~+\~C's\~vt)/2, effectively landing in the middle between A's and C's
 virtual time. The effect \- B, having no RT guarantees, will be punished and
 will not be allowed to transfer until C's virtual time catches up.
 
-If the interface had higher capacity \- for example 100mbit, this example
+If the interface had a higher capacity, for example 100Mbit, this example
 would behave perfectly fine though.
 
 Let's look a bit closer at the above example \- it "cleverly" invalidates one
@@ -401,8 +402,8 @@ of the basic things LS criterion tries to achieve \- equality of all virtual
 times across class hierarchy. Leaf classes without RT service curves are
 literally left to their own fate (governed by messed up virtual times).
 
-Also - it doesn't make much sense. Class A will always be guaranteed up to
-8mbit, and this is more than any absolute bandwidth that could happen from its
+Also, it doesn't make much sense. Class A will always be guaranteed up to
+8Mbit, and this is more than any absolute bandwidth that could happen from its
 LS criterion (excluding trivial case of only A being active). If the bandwidth
 taken by A is smaller than absolute value from LS criterion, the unused part
 will be automatically assigned to other active classes (as A has idling periods
@@ -411,7 +412,7 @@ average, bursts would be handled at the speed defined by RT criterion. Still,
 if extra speed is needed (e.g. due to latency), non linear service curves
 should be used in such case.
 
-In the other words - LS criterion is meaningless in the above example.
+In the other words: the LS criterion is meaningless in the above example.
 
 You can quickly "workaround" it by making sure each leaf class has RT service
 curve assigned (thus guaranteeing all of them will get some bandwidth), but it
@@ -422,13 +423,13 @@ happen \fIonly\fR in the first segment, then there's little wrong with
 "overusing" RT curve a bit:
 
 .nf
-A \- ls 5.0mbit, rt 9mbit/30ms, then 1mbit
-B \- ls 2.5mbit
-C \- ls 2.5mbit
+A \- ls 5.0Mbit, rt 9Mbit/30ms, then 1Mbit
+B \- ls 2.5Mbit
+C \- ls 2.5Mbit
 .fi
 
 Here, the vt of A will "spike" in the initial period, but then A will never get more
-than 1mbit, until B & C catch up. Then everything will be back to normal.
+than 1Mbit until B & C catch up. Then everything will be back to normal.
 .
 .SH "LINUX AND TIMER RESOLUTION"
 .
@@ -457,43 +458,43 @@ or aren't available.
 
 This is important to keep those settings in mind, as in scenario like: no
 tickless, no HR timers, frequency set to 100hz \- throttling accuracy would be
-at 10ms. It doesn't automatically mean you would be limited to ~0.8mbit/s
+at 10ms. It doesn't automatically mean you would be limited to ~0.8Mbit/s
 (assuming packets at ~1KB) \- as long as your queues are prepared to cover for
-timer inaccuracy. Of course, in case of e.g. locally generated udp traffic \-
+timer inaccuracy. Of course, in case of e.g. locally generated UDP traffic \-
 appropriate socket size is needed as well. Short example to make it more
 understandable (assume hardcore anti\-schedule settings \- HZ=100, no HR
 timers, no tickless):
 
 .nf
 tc qdisc add dev eth0 root handle 1:0 hfsc default 1
-tc class add dev eth0 parent 1:0 classid 1:1 hfsc rt m2 10mbit
+tc class add dev eth0 parent 1:0 classid 1:1 hfsc rt m2 10Mbit
 .fi
 
-Assuming packet of ~1KB size and HZ=100, that averages to ~0.8mbit \- anything
-beyond it (e.g. the above example with specified rate over 10x bigger) will
+Assuming packet of ~1KB size and HZ=100, that averages to ~0.8Mbit \- anything
+beyond it (e.g. the above example with specified rate over 10x larger) will
 require appropriate queuing and cause bursts every ~10 ms. As you can
 imagine, any HFSC's RT guarantees will be seriously invalidated by that.
 Aforementioned example is mainly important if you deal with old hardware \- as
-it's particularly popular for home server chores. Even then, you can easily
+is particularly popular for home server chores. Even then, you can easily
 set HZ=1000 and have very accurate scheduling for typical adsl speeds.
 
 Anything modern (apic or even hpet msi based timers + \&'tickless system')
-will provide enough accuracy for superb 1gbit scheduling. For example, on one
-of basically cheap dual core AMD boards I have with following settings:
+will provide enough accuracy for superb 1Gbit scheduling. For example, on one
+of my cheap dual-core AMD boards I have the following settings:
 
 .nf
 tc qdisc add dev eth0 parent root handle 1:0 hfsc default 1
-tc class add dev eth0 paretn 1:0 classid 1:1 hfsc rt m2 300mbit
+tc class add dev eth0 parent 1:0 classid 1:1 hfsc rt m2 300mbit
 .fi
 
-And simple:
+And a simple:
 
 .nf
 nc \-u dst.host.com 54321 </dev/zero
 nc \-l \-p 54321 >/dev/null
 .fi
 
-\&...will yield following effects over period of ~10 seconds (taken from
+\&...will yield the following effects over a period of ~10 seconds (taken from
 /proc/interrupts):
 
 .nf
@@ -502,16 +503,16 @@ nc \-l \-p 54321 >/dev/null
 .fi
 
 That's roughly 31000/s. Now compare it with HZ=1000 setting. The obvious
-drawback of it is that cpu load can be rather extensive with servicing that
-many timer interrupts. Example with 300mbit RT service curve on 1gbit link is
+drawback of it is that cpu load can be rather high with servicing that
+many timer interrupts. The example with 300Mbit RT service curve on 1Gbit link is
 particularly ugly, as it requires a lot of throttling with minuscule delays.
 
-Also note that it's just an example showing capability of current hardware.
-The above example (essentially 300mbit TBF emulator) is pointless on internal
-interface to begin with \- you will pretty much always want regular LS service
-curve there, and in such scenario HFSC simply doesn't throttle at all.
+Also note that it's just an example showing the capabilities of current hardware.
+The above example (essentially a 300Mbit TBF emulator) is pointless on an internal
+interface to begin with: you will pretty much always want a regular LS service
+curve there, and in such a scenario HFSC simply doesn't throttle at all.
 
-300mbit RT service curve (selected columns from mpstat \-P ALL 1):
+300Mbit RT service curve (selected columns from mpstat \-P ALL 1):
 
 .nf
 10:56:43 PM  CPU  %sys     %irq   %soft   %idle
@@ -520,28 +521,28 @@ curve there, and in such scenario HFSC simply doesn't throttle at all.
 10:56:44 PM    1   4.95   12.87    6.93   73.27
 .fi
 
-So, in rare case you need those speeds with only RT service curve, or with UL
-service curve \- remember about drawbacks.
+So, in the rare case you need those speeds with only a RT service curve, or with a UL
+service curve: remember the drawbacks.
 .
 .SH "CAVEAT: RANDOM ONLINE EXAMPLES"
 .
 For reasons unknown (though well guessed), many examples you can google love to
 overuse UL criterion and stuff it in every node possible. This makes no sense
 and works against what HFSC tries to do (and does pretty damn well). Use UL
-where it makes sense - on the uppermost node to match upstream router's uplink
-capacity. Or - in special cases, such as testing (limit certain subtree to some
-speed) or customers that must never get more than certain speed. In the last
-case you can usually achieve the same by just using RT criterion without LS+UL
+where it makes sense: on the uppermost node to match upstream router's uplink
+capacity. Or in special cases, such as testing (limit certain subtree to some
+speed), or customers that must never get more than certain speed. In the last
+case you can usually achieve the same by just using a RT criterion without LS+UL
 on leaf nodes.
 
-As for router case - remember it's good to differentiate between "traffic to
+As for the router case - remember it's good to differentiate between "traffic to
 router" (remote console, web config, etc.) and "outgoing traffic", so for
 example:
 
 .nf
 tc qdisc add dev eth0 root handle 1:0 hfsc default 0x8002
-tc class add dev eth0 parent 1:0 classid 1:999 hfsc rt m2 50mbit
-tc class add dev eth0 parent 1:0 classid 1:1 hfsc ls m2 2mbit ul m2 2mbit
+tc class add dev eth0 parent 1:0 classid 1:999 hfsc rt m2 50Mbit
+tc class add dev eth0 parent 1:0 classid 1:1 hfsc ls m2 2Mbit ul m2 2Mbit
 .fi
 
 \&... so "internet" tree under 1:1 and "router itself" as 1:999
