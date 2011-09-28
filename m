From: Jan Kozel <jkozel@neviol.cz>
Subject: HTB TC Problem up 800 - 2000 class
Date: Wed, 28 Sep 2011 11:08:25 +0200
Message-ID: <4E82E409.1010806@neviol.cz>
References: <4E82E0AF.1020709@neviol.cz>
Reply-To: jkozel@neviol.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmail.neviol.cz ([93.185.0.37]:60014 "EHLO vmail.neviol.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839Ab1I1JI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 05:08:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by vmail.neviol.cz (Postfix) with ESMTP id B2D7B804780
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 11:21:38 +0200 (CEST)
Received: from vmail.neviol.cz ([127.0.0.1])
	by localhost (vmail.neviol.cz [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zqho1HS1HmOo for <netdev@vger.kernel.org>;
	Wed, 28 Sep 2011 11:21:37 +0200 (CEST)
Received: from [192.168.254.103] (unknown [94.229.93.163])
	by vmail.neviol.cz (Postfix) with ESMTPA id 7A35B804686
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 11:21:37 +0200 (CEST)
In-Reply-To: <4E82E0AF.1020709@neviol.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Hi

  I have a problem I use the TC HTB and IFB. Shaper limits absolutely 
without any problems until 1GB/ps throughput, but only for about 750 
clients. At a time when the state tables for TC and  MAMGLE exceeds 1000 
clients thewill be the load average to 0.7 and bandwidth shaper is 
rapidly reduced and drops down to 200Mb. I attach the script for the 
first clients. You do not have anyone experiences that for 2000 and more 
restrictions?

# downlink eth1
/sbin/tc qdisc add dev eth1 handle 1: root htb default 99 r2q 1800
# uplink eth0
/sbin/tc qdisc add dev eth0 handle 1: root htb default 99 r2q 1800
/sbin/tc class add dev eth1 parent 1:0 classid 1:2 htb rate 1240kbit ceil 1240kbit quantum 103 prio 1
/sbin/tc class add dev eth0 parent 1:0 classid 1:2 htb rate 1240kbit ceil 1240kbit quantum 103 prio 1
/sbin/tc class add dev eth1 parent 1:0 classid 1:1 htb rate 999000kbit ceil 999040kbit quantum 83253 prio 1
/sbin/tc class add dev eth0 parent 1:0 classid 1:1 htb rate 999000kbit ceil 999040kbit quantum 83253 prio 1
/sbin/tc class add dev eth1 parent 1:1 classid 1:3 htb rate 2560kbit ceil 2560kbit quantum 213 prio 1
/sbin/tc class add dev eth0 parent 1:1 classid 1:3 htb rate 2560kbit ceil 2560kbit quantum 213 prio 1
/sbin/tc class add dev eth1 parent 1:2 classid 1:4 htb rate 2560kbit ceil 2560kbit quantum 213 prio 1
/sbin/tc class add dev eth0 parent 1:2 classid 1:4 htb rate 2560kbit ceil 2560kbit quantum 213 prio 1
/sbin/tc class add dev eth1 parent 1:1 classid 1:10 htb rate 1000kbit ceil 1001kbit quantum 83 prio 1
/sbin/tc class add dev eth0 parent 1:1 classid 1:10 htb rate 1000kbit ceil 1001kbit quantum 83 prio 1
# Jednolivi klienti -- rychlsoti
echo Aktivuji IP 94.229.95.162
/sbin/tc class add dev eth1 parent 1:1 classid 1:1686 htb rate 800kbit ceil 8000kbit quantum 666 prio 1
/sbin/tc qdisc add dev eth1 parent 1:1686 handle 1686 esfq
/sbin/tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip dst 94.229.95.162 flowid 1:1686 action mirred egress redirect dev ifb0

/sbin/tc class add dev eth0 parent 1:1 classid 1:3336 htb rate 204kbit ceil 2048kbit quantum 170 prio 1
/sbin/tc qdisc add dev eth0 parent 1:3336 handle 3336 esfq
/usr/src/iptables-1.4.3.2/iptables -t mangle -A POSTROUTING -s 94.229.95.162 -j MARK --set-mark 3336
/sbin/tc filter add dev eth0 parent 1:0 prio 1 protocol ip handle 3336 fw flowid 1:3336


echo Aktivuji IP 192.168.1.2
/sbin/tc class add dev eth1 parent 1:1 classid 1:107 htb rate 30000kbit ceil 300000kbit quantum 25000 prio 1
/sbin/tc qdisc add dev eth1 parent 1:107 handle 107 esfq
/sbin/tc filter add dev eth1 protocol ip parent 1: prio 1 u32 match ip dst 192.168.1.2 flowid 1:107 action mirred egress redirect dev ifb0

/sbin/tc class add dev eth0 parent 1:1 classid 1:1757 htb rate 30000kbit ceil 300000kbit quantum 25000 prio 1
/sbin/tc qdisc add dev eth0 parent 1:1757 handle 1757 esfq
/usr/src/iptables-1.4.3.2/iptables -t mangle -A POSTROUTING -s 192.168.1.2 -j MARK --set-mark 1757
/sbin/tc filter add dev eth0 parent 1:0 prio 1 protocol ip handle 1757 fw flowid 1:1757

	thank you

		Kozel Jan


-- 
