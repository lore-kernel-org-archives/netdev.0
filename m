From: =?UTF-8?B?SXJlbmV1c3ogU3pjemXFm25pYWs=?=
	<irek.szczesniak@gmail.com>
Subject: tc: problem with nested classes
Date: Sun, 22 Apr 2012 14:52:09 +0200
Message-ID: <4F93FEF9.2050307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47654 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab2DVMwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 08:52:14 -0400
Received: by wejx9 with SMTP id x9so6932692wej.19
        for <netdev@vger.kernel.org>; Sun, 22 Apr 2012 05:52:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a problem understanding nested classes in tc (traffic control).

To introduce the problem, I briefly describe how I think the tc works. 
  There are qdiscs, classes and filters.  A qdisc can have classes, 
and filters configured for this qdisc classify packets.  When a packet 
is enqueue to a qdisc, filters decide which class the packet belongs 
to, i.e. filters classify packets.  Each class has a qdisc, by default 
the pfifo class, and so classifying implies enqueing a packet in the 
queue of class the packet was classified to.

Therefore I would claim that a class cannot have another class as a 
child, because the child should be a qdisc.  However, Example 1 shows 
that I'm wrong.

Example 1
---------

tc qdisc add dev eth0 root handle 1:0 htb
tc class add dev eth0 parent 1:0 classid 1:1 htb rate 10mbit
tc class add dev eth0 parent 1:1 classid 1:2 htb rate 1mbit

In this example class 1:1 is a parent of both classes 1:2 and 1:3.

QUESTION 1: Does class 1:1 have a queue?

Example 2 implements the same functionality as Example 1, I think.

Example 2
---------

tc qdisc add dev eth0 root handle 1:0 htb
tc class add dev eth0 parent 1:0 classid 1:1 htb rate 10mbit
tc qdisc add dev eth0 parent 1:1 handle 2:0 htb
tc class add dev eth0 parent 2:0 classid 2:1 htb rate 1mbit

QUESTION 2: Is there a difference between Example 1 and Example 2?

QUESTION 3: What is "-d" for in "tc -s -d qdisc"

QUESTION 4: How can I view the statistics for default queues of 
classes, those pfifo queues?  "tc -s qdisc" doesn't show them.

QUESTION 5: Why in filters there is used "flowid" instead of "parent"?

I would appreciate it if someone could answer my questions.

-- 
Ireneusz (Irek) Szczesniak
http://www.irkos.org
