From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Request to include ESFQ patch
Date: Wed, 2 Jan 2008 18:10:30 +0200
Message-ID: <20080102155903.M66678@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: bugfood-c@fatooh.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:60495 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172AbYABQVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 11:21:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I took risk and installed ESFQ on my main backbone QoS. I found it highly 
useful, and very need in setup's where is more than 128 flows passing and 
especially where is nat available.

Here is results with overloaded class for low-priority P2P traffic customers:

pfifo 128Kbyte, bandwidth 512Kbit/s
... cut ...
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=27 ttl=51 
time=228 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=28 ttl=51 
time=247 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=29 ttl=51 
time=415 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=30 ttl=51 
time=198 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=31 ttl=51 
time=2274 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=32 ttl=51 
time=2237 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=33 ttl=51 
time=2235 ms
... cut ...
--- www.nuclearcat.com ping statistics ---
100 packets transmitted, 98 received, 2% packet loss, time 99006ms
rtt min/avg/max/mdev = 155.647/1022.177/2289.229/881.461 ms, pipe 3


ping is very unstable, there is drops also. And i dont use almost traffic.

sfq
... cut ...
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=61 ttl=51 
time=1136 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=62 ttl=51 
time=930 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=63 ttl=51 
time=1057 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=64 ttl=51 
time=1055 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=65 ttl=51 
time=1012 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=66 ttl=51 
time=880 ms
... cut ...
--- www.nuclearcat.com ping statistics ---
100 packets transmitted, 95 received, 5% packet loss, time 98984ms
rtt min/avg/max/mdev = 157.328/479.812/1136.569/331.170 ms, pipe 2

Also not so stable, buffer in sfq is 128packets, on average packet 500 bytes 
it will be around 64000 bytes, about 1 second delay only (while i need for 
test 2 second). Packetloss very high.

esfq: perturb 30 depth 65536 divisor 14 limit 256 hash ctorigdst
... cut ...
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=12 ttl=51 
time=185 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=13 ttl=51 
time=238 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=14 ttl=51 
time=228 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=15 ttl=51 
time=377 ms
64 bytes from usa.nuclearcat.com (66.230.167.210): icmp_seq=16 ttl=51 
time=177 ms
... cut ...
--- www.nuclearcat.com ping statistics ---
100 packets transmitted, 100 received, 0% packet loss, time 99009ms
rtt min/avg/max/mdev = 154.254/208.048/553.740/58.716 ms

This is worst jitter, other looks fine.
ping just great, no packetloss, even jitter is acceptable. This queue just my 
dream.

Conclusion:
There is no fair queue qdisc available for "serious" setup. ESFQ only one 
real pretendent i seen for today, to be included in kernel. And probably it 
will be highly useful feature.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

