From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Controlling TCP window size
Date: Tue, 16 May 2006 12:06:57 +0100
Message-ID: <4469B251.3050901@andyfurniss.entadsl.com>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:2789 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S1751775AbWEPLFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 07:05:37 -0400
Received: from [192.168.0.3] (unknown [87.127.23.106])
	by mail.ukfsn.org (Postfix) with ESMTP id 19633E7029
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:58:42 +0100 (BST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've been doing some testing of my new wan connection and noticed that 
when I specify a window with ip route it still changes after a while.

Using 2.6.16.11 and latest iproute2.

ip ro del default
ip ro add default via 192.168.0.1 window 28000
ip ro ls
192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.3
default via 192.168.0.1 dev eth0  window 28000

timestamps and window scaling are off using reno.

Downloading a 5 meg file I advertise the correct window - the whole 
multiple of my mss below 28000 = 27322.

After about 1300 lines of the dump the window creeps back up to 32767.

001959 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1051979:1053417(1438) 
ack 123 win 57520
000011 IP 192.168.0.3.42305 > 81.31.115.186.80: . ack 1053417 win 27322
002030 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1053417:1054855(1438) 
ack 123 win 57520
001962 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1054855:1056293(1438) 
ack 123 win 57520
000011 IP 192.168.0.3.42305 > 81.31.115.186.80: . ack 1056293 win 27322
003020 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1056293:1057731(1438) 
ack 123 win 57520
001968 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1057731:1059169(1438) 
ack 123 win 57520
000012 IP 192.168.0.3.42305 > 81.31.115.186.80: . ack 1059169 win 30198
002024 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1059169:1060607(1438) 
ack 123 win 57520
000012 IP 192.168.0.3.42305 > 81.31.115.186.80: . ack 1060607 win 32767
001980 IP 81.31.115.186.80 > 192.168.0.3.42305: . 1060607:1062045(1438) 
ack 123 win 57520
000011 IP 192.168.0.3.42305 > 81.31.115.186.80: . ack 1062045 win 32767

Andy.

