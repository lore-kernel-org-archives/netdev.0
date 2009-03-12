From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: DRR example, how to replace SFQ
Date: Thu, 12 Mar 2009 02:01:49 +0200
Message-ID: <200903120201.49195.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43887 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbZCLAB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 20:01:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If i understand right, it must look like this to simulate SFQ 
This example with just 2 "queues".

tc qdisc add dev eth0.100 root handle 1: htb

tc class add dev eth0.100 parent 1: classid 1:1 htb rate 15Kbit ceil 15Kbit

tc qdisc add dev eth0.100 parent 1:1 handle 2: drr

tc class add dev eth0.100 parent 2: classid 2:1 drr quantum 1600
tc class add dev eth0.100 parent 2: classid 2:2 drr quantum 1600

tc qdisc add dev eth0.100 parent 2:1 handle 10: bfifo 9000
tc qdisc add dev eth0.100 parent 2:2 handle 11: bfifo 9000

tc filter add dev eth0.100 parent 1: protocol ip prio 5 u32 match u32 0 0 
flowid 1:1

tc filter add dev eth0.100 parent 2: protocol ip prio 10 handle 1 flow keys 
dst divisor 2 baseclass 2:1

Is it correct?
