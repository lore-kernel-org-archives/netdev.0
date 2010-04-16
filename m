From: unni krishnan <unnikrishnan.a@gmail.com>
Subject: Duplicate IP false alerts from arping
Date: Fri, 16 Apr 2010 12:21:30 +0530
Message-ID: <m2v1f8bbe3c1004152351o580b37ebx55e428fb106b09bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:41810 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab0DPGvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:51:32 -0400
Received: by qw-out-2122.google.com with SMTP id 8so741852qwh.37
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 23:51:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to find a duplicate IP in the network using arping.

-------------------------
[root@vps1 ~]# ping -c 3 192.168.1.212
PING 192.168.1.212 (192.168.1.212) 56(84) bytes of data.
64 bytes from 192.168.1.212: icmp_seq=1 ttl=64 time=1.33 ms
64 bytes from 192.168.1.212: icmp_seq=2 ttl=64 time=0.280 ms
64 bytes from 192.168.1.212: icmp_seq=3 ttl=64 time=0.306 ms

--- 192.168.1.212 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.280/0.641/1.339/0.494 ms
[root@vps1 ~]# arping -D -I eth0 -c 5 192.168.1.212 ; echo $?
ARPING 192.168.1.212 from 0.0.0.0 eth0
0
-------------------------


As per arping that IP is duplicate. But if I go ahead and ifdown the
IP in the known location I cant ping that IP ( That means that IP is
not duplicated ? ). This is the result after shutting down the IP.

--------------------------
[root@vps1 ~]# ping -c 3 192.168.1.212
PING 192.168.1.212 (192.168.1.212) 56(84) bytes of data.
>From 192.168.1.63 icmp_seq=1 Destination Host Unreachable
>From 192.168.1.63 icmp_seq=2 Destination Host Unreachable
>From 192.168.1.63 icmp_seq=3 Destination Host Unreachable

--- 192.168.1.212 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2001ms
, pipe 3
[root@vps1 ~]# arping -D -I eth0 -c 5 192.168.1.212 ; echo $?
ARPING 192.168.1.212 from 0.0.0.0 eth0
Sent 5 probes (5 broadcast(s))
Received 0 response(s)
0
[root@vps1 ~]#
--------------------------

My question is, in this case IP 192.168.1.212 is not duplicated. But
still arping gives duplicate status. Why it is like that ?

-- 
Regards,
Unni
http://mutexes.org/
http://twitter.com/webofunni
