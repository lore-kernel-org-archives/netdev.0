From: rbj2@njit.edu
Subject: RED + ECN not working
Date: Tue, 09 Jan 2007 11:08:04 -0500 (EST)
Message-ID: <1168358884.45a3bde4a14b9@webmail.njit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: rbj2@njit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw4.njit.edu ([128.235.251.32]:42211 "EHLO
	mail-gw4.njit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176AbXAIQIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 11:08:11 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have been trying to get the RED qdisc and ECN to work for the past few weeks
and all my experiments have failed. Here is the setup I am using. 

Src -- R1 -- R2 -- Dst

Between Src and R1 is a 100Mbps link and between R1 and R2 a 10Mbps link. I set up
the qdisc at R1 as follows

tc qdisc add dev eth3 root handle 1: prio
tc qdisc add dev eth3 parent 1:1 handle 10: sfq
tc qdisc add dev eth3 parent 1:2 handle 20: sfq
tc qdisc add dev eth3 parent 1:3 handle 30: red limit 10000 min 3000 max 5000
avpkt 1000 burst 5 probability 0.5 bandwidth 256kbit ecn

I also inserted printk statments inside the code to print the calculate queue average (RED param), the 
backlog (Qdisc param) and the queue length (sk_buff_head param). I also inserted print statements for 
each action of RED i.e. DONT_MARK, PROB_MARK, HARD_MARK and DROP.

For the purpose of my experiments, I transferred a 25 MB file. I also did 100 simultaneous TCP 
transfers for 2 mins using ipref. In all cases none of the packets were either marked or dropped by the 
RED code. This was verified by the print statements in the logs. For all runs, qavg and backlog were 0 
and qlen was 1. 

I have even tried classless red and got same results. Does anyone know whether RED+ECN work ? Any 
tests and setups that someone has used and got successful results ? I would really appreciate any input 
or suggestions on this.

Thanks,
Rahul.
