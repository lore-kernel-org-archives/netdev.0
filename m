From: mpe <michele@unipex.it>
Subject: syn connection not replied with ack
Date: Tue, 28 Aug 2012 19:03:41 +0200
Message-ID: <k1itlc$kef$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:46456 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634Ab2H1RKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 13:10:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T6PIi-0003bK-4Q
	for netdev@vger.kernel.org; Tue, 28 Aug 2012 19:10:04 +0200
Received: from gw.corp.inasset.net ([82.193.33.243])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 19:10:04 +0200
Received: from michele by gw.corp.inasset.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 19:10:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I have very very strange behaviour with a virtual machine (centos 6 
up-to-date).
Then I try to connect to it with a linux ssh client, I see the syn, but 
not the syn-ack replied. On the same target when I connect with windows 
machine, it reply correctly and the communication starts.

tshark show me with linux:
386.134073 172.18.0.160 -> 172.18.0.254 TCP 45092 > ssh [SYN] Seq=0 
Win=4240 Len=0 MSS=1060 TSV=497047 TSER=0 WS=5
389.134556 172.18.0.160 -> 172.18.0.254 TCP 45092 > ssh [SYN] Seq=0 
Win=4240 Len=0 MSS=1060 TSV=497798 TSER=0 WS=5
395.134926 172.18.0.160 -> 172.18.0.254 TCP 45092 > ssh [SYN] Seq=0 
Win=4240 Len=0 MSS=1060 TSV=499298 TSER=0 WS=5

and windows:
1099.091686 172.18.0.141 -> 172.18.0.254 TCP 32906 > ssh [SYN] Seq=0 
Win=8192 Len=0 MSS=1260 WS=8
1099.092934 172.18.0.254 -> 172.18.0.141 TCP ssh > 32906 [SYN, ACK] 
Seq=0 Ack=1 Win=5840 Len=0 MSS=1380
1099.092960 172.18.0.141 -> 172.18.0.254 TCP 32906 > ssh [ACK] Seq=1 
Ack=1 Win=65520 Len=0
1099.102017 172.18.0.254 -> 172.18.0.141 SSH Server Protocol: 
SSH-2.0-OpenSSH_4.3

iptables are disabled, no modules active (lsmod | grep ip show nothing)
I tried also to remove the vmware vmxnet3 module, reloaded, network 
restart, but the same.

But... if I reboot, the communication start for the next 2/3 days and 
after it stops another time.

Hope that someone can help me.

Michele
