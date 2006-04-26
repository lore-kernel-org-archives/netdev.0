From: George Nychis <gnychis@cmu.edu>
Subject: how to change classful netem loss probability?
Date: Wed, 26 Apr 2006 18:46:30 -0400
Message-ID: <444FF846.7050600@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.81]:31402 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP id S964878AbWDZWqf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:46:35 -0400
To: LARTC@mailman.ds9a.nl, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am using netem to add loss and then adding another qdisc within netem 
according to the wiki.  Then i want to change the netem drop probability 
without having to delete the qdisc and recreate it.  I try it but I get 
invalid argument:

thorium-ini hedpe # tc qdisc add dev ath0 root handle 1:0 netem drop 1%
thorium-ini hedpe # tc qdisc add dev ath0 parent 1:1 handle 10: xcp 
capacity 54Mbit limit 500
thorium-ini hedpe # tc -s qdisc ls dev ath0
qdisc netem 1: limit 1000 loss 1%
  Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
qdisc xcp 10: parent 1:1 capacity 52734Kbit limit 500p
  Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
thorium-ini hedpe # tc qdisc change dev ath0 root handle 1:0 netem drop 1%
RTNETLINK answers: Invalid argument
thorium-ini hedpe # tc qdisc change dev ath0 root netem drop 1%
RTNETLINK answers: Invalid argument

any ideas?

Thanks!
George
