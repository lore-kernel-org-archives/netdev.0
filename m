From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: pkt_sched: add DRR scheduler, any idea how to use it?
Date: Thu, 26 Feb 2009 18:26:17 +0200
Message-ID: <200902261826.17228.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38896 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbZBZQwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:52:21 -0500
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 4EC6A1A44AE
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 18:52:14 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried

c qdisc add dev ifb0 handle 1 root htb

tc class add dev ifb0 classid 1:100 parent 1:0 htb rate 100Kbit ceil 100Kbit
tc qdisc add dev ifb0 parent 1:100 handle 2 drr

Packets directed by filter to 1:100, all gots dropped. And even i am adding
tc class add dev ifb0 parent 2:0 classid 2:1 drr quantum 16384

or 

tc class add dev ifb0 parent 2:0 classid 2:0 drr quantum 16384

or 

tc class add dev ifb0 parent 2:0 classid 2:1 drr quantum 16384
tc qdisc add dev ifb0 parent 2:1 handle 3 bfifo limit 10000


Always it is 
qdisc drr 2: parent 1:100
 Sent 0 bytes 0 pkt (dropped 32, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

Any simple example how to use it?
