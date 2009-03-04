From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [BUG?] iproute2/skbedit bug?
Date: Wed, 4 Mar 2009 21:46:37 +0200
Message-ID: <200903042146.37807.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59163 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353AbZCDTqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:46:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

trying to do test case:

defaulthost ~ # tc qdisc del dev eth0 root handle 1: htb
defaulthost ~ # tc qdisc add dev eth0 root handle 1: htb
defaulthost ~ # tc class add dev eth0 parent 1:0 classid 1:1 htb rate 100Mbit 
ceil 100Mbit
defaulthost ~ #
defaulthost ~ # tc class add dev eth0 parent 1:1 classid 1:2 htb rate 100Mbit 
ceil 100Mbit
defaulthost ~ # tc qdisc add dev eth0 parent 1:2 handle 2: pfifo limit 1000
defaulthost ~ #
defaulthost ~ #
defaulthost ~ # tc filter add dev eth0 pref 200 parent 1: protocol ip u32 
match ip src 1.1.1.1/32 flowid 1:1 action skbedit priority 10
defaulthost ~ # tc filter add dev eth0 pref 201 parent 1: protocol ip u32 
match ip src 1.1.1.2/32 flowid 1:2 action skbedit priority 11
RTNETLINK answers: File exists
We have an error talking to the kernel

As soon as skbedit involved, i am getting this strange result "File exists".
If i change(remove) flowid, classes - seems doesn't matter

Result looks like this:
defaulthost ~ # tc -s filter show dev eth0
filter parent 1: protocol ip pref 200 u32
filter parent 1: protocol ip pref 200 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 200 u32 fh 800::800 order 2048 key ht 800 
bkt 0 flowid 1:1  (rule hit 460 success 0)
  match 01010101/ffffffff at 12 (success 0 )
        action order 1:  skbedit priority :10 installed 82 sec used 82 sec      
Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

filter parent 1: protocol ip pref 201 u32
filter parent 1: protocol ip pref 201 u32 fh 801: ht divisor 1

If i remove skbedit:
defaulthost ~ # tc filter add dev eth0 pref 200 parent 1: protocol ip u32 
match ip src 1.1.1.1/32 flowid 1:1
defaulthost ~ #                                                                                                                            

