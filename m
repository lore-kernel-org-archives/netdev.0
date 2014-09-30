From: Rick Jones <rick.jones2@hp.com>
Subject: Philosophical question:  Is a UDP multicast datagram for which there
 is no socket match a drop or an ignore?
Date: Tue, 30 Sep 2014 16:09:37 -0700
Message-ID: <542B3831.5030701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:15638 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbaI3XJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:09:39 -0400
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t3425.houston.hp.com (Postfix) with ESMTP id E3710C3
	for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 23:09:38 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id B233F71
	for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 23:09:38 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been looking at some additional perf <mutter> -e skb_kfree_skb 
results, this time with a laptop connected to a corporate network with a 
large number of Windows systems sending out what they are wont to 
send...  The laptop is just sitting there no active netperfs or anything :)

I see profile hits for __udp4_lib_mcast_deliver() which has a 
kfree_skb() call which will happen if either there were no sockets 
found, or if an integral multiple of ARRAY_SIZE(stack) sockets are 
found.  I'm assuming the latter is exceedingly rare.

Anywho, the philosophical question - is such a situation a drop 
(indicating the existing kfree_skb()), or is it an ignore (indicating a 
consume_skb())?  Should there be a statistic incremented for either of 
those?

happy benchmarking,

rick jones
