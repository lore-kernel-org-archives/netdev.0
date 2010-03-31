From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: iproute u32 filter - server hang
Date: Wed, 31 Mar 2010 11:10:07 +0200
Message-ID: <4BB3116F.803@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:46861 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757209Ab0CaJKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 05:10:14 -0400
Received: from unknown (HELO [192.168.1.101]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp2.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 31 Mar 2010 09:10:12 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find some problem with iproute2 and u32 filters

To reproduce the problem (need to make one mistake in filter parent=20
declaration 1:101):

tc qdisc add dev eth0 root handle 1: hfsc default 63
tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 100mbit ul rat=
e=20
100mbit
tc class add dev eth0 parent 1:1 classid 1:2 hfsc sc rate 1mbit ul rate=
=20
1mbit
tc class add dev eth0 parent 1:1 classid 1:63 hfsc sc rate 99mbit ul=20
rate 99mbit
tc class add dev eth0 parent 1:1 classid 1:101 hfsc sc rate 8kbit ul=20
rate 1mbit
tc class add dev eth0 parent 1:101 classid 1:102 hfsc sc rate 8kbit ul=20
rate 1mbit
tc filter add dev eth0 protocol ip parent 1: u32 match ip dst=20
212.77.100.101 flowid 1:101
tc filter add dev eth0 protocol ip parent 1:101 u32 match ip protocol 1=
=20
0xff flowid 1:101

ping 212.77.100.101
And after this server will stop responding to anything - without any=20
error (hang).



With a little different rules:
tc qdisc add dev eth0 root handle 1: hfsc default 63
tc class add dev eth0 parent 1: classid 1:1 hfsc sc rate 100mbit ul rat=
e=20
100mbit
tc class add dev eth0 parent 1:1 classid 1:2 hfsc sc rate 1mbit ul rate=
=20
1mbit
tc class add dev eth0 parent 1:1 classid 1:63 hfsc sc rate 99mbit ul=20
rate 99mbit
tc class add dev eth0 parent 1:1 classid 1:101 hfsc sc rate 8kbit ul=20
rate 1mbit
tc class add dev eth0 parent 1:101 classid 1:102 hfsc sc rate 8kbit ul=20
rate 1mbit
tc filter add dev eth0 protocol ip parent 1: u32 match ip dst=20
212.77.100.101 flowid 1:101
tc filter add dev eth0 protocol ip parent 1: u32 match ip protocol 1=20
0xff flowid 1:101

ping 212.77.100.101
All is ok.

I check this with kernels 2.6.30.1 / 2.6.33 / 2.6.33.1
iproute tc utility version: iproute2-ss090324



Best Regards
Pawe=C5=82 Staszewski
