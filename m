From: "Damon L. Chesser" <damon@damtek.com>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Thu, 08 May 2008 14:16:29 -0400
Message-ID: <4823437D.20005@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090901050407010403020208"
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from damtek.com ([72.172.134.65]:41563 "EHLO damtek.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755516AbYEHSQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 14:16:06 -0400
In-Reply-To: <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090901050407010403020208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Ilpo Järvinen wrote:
> SNIP

>
> Could you next try with tcp_frto set to 1, if my theory proves to be 
> correct, it too should be "enough" to fix the problem (in this 
> particular case). Of course you can verify the patch below too if you 
> want to, the patch should allow cups<->printer to work with tcp_frto = 
> 2 too. In case you have problem to apply the patch to the particular 
> version you're want to try with, just send a note about the version 
> number to me so I can adapt the patch for you (space etc. formatting 
> issues may show up because I recently run a code style cleanup on the 
> tcp code).

Ilpo,

reran the print job with the correct kernel (for control reasons) and 
received the same results:  tcp_frto=1 no print.  tcp_frto=0 I can 
print.  Attached is the output of tcpdump

uname -r = 2.6.24-1-amd64

Thanks for the work!


-- 
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser


--------------090901050407010403020208
Content-Type: text/plain;
 name="frtoprob2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="frtoprob2.txt"

1210269685.442292 IP (tos 0x0, ttl 64, id 65247, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 1730585386:1730585898(512) ack 129179649 win 5840
1210269685.446179 IP (tos 0x0, ttl 100, id 22, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x7134 (correct), 1:1(0) ack 512 win 1024
1210269685.446221 IP (tos 0x0, ttl 64, id 65248, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 1024:1536(512) ack 1 win 5840
1210269686.140866 IP (tos 0x0, ttl 100, id 23, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x7134 (correct), 1:1(0) ack 512 win 1024
1210269714.626282 IP (tos 0x0, ttl 64, id 65249, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 512:1024(512) ack 1 win 5840
1210269714.632392 IP (tos 0x0, ttl 100, id 24, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6f34 (correct), 1:1(0) ack 1024 win 1024
1210269714.632425 IP (tos 0x0, ttl 64, id 65250, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 1536:2048(512) ack 1 win 5840
1210269715.327141 IP (tos 0x0, ttl 100, id 25, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6f34 (correct), 1:1(0) ack 1024 win 1024
1210269772.998283 IP (tos 0x0, ttl 64, id 65251, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 1024:1536(512) ack 1 win 5840
1210269773.005111 IP (tos 0x0, ttl 100, id 29, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6d34 (correct), 1:1(0) ack 1536 win 1024
1210269773.005144 IP (tos 0x0, ttl 64, id 65252, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 2048:2560(512) ack 1 win 5840
1210269773.704682 IP (tos 0x0, ttl 100, id 30, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6d34 (correct), 1:1(0) ack 1536 win 1024
1210269889.738282 IP (tos 0x0, ttl 64, id 65253, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 1536:2048(512) ack 1 win 5840
1210269889.745981 IP (tos 0x0, ttl 100, id 37, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6b34 (correct), 1:1(0) ack 2048 win 1024
1210269889.746012 IP (tos 0x0, ttl 64, id 65254, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 2560:3072(512) ack 1 win 5840
1210269890.444886 IP (tos 0x0, ttl 100, id 38, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6b34 (correct), 1:1(0) ack 2048 win 1024
1210270009.746305 IP (tos 0x0, ttl 64, id 65255, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 2048:2560(512) ack 1 win 5840
1210270009.752297 IP (tos 0x0, ttl 100, id 42, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6934 (correct), 1:1(0) ack 2560 win 1024
1210270009.752335 IP (tos 0x0, ttl 64, id 65256, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: P 3072:3584(512) ack 1 win 5840
1210270010.449445 IP (tos 0x0, ttl 100, id 43, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6934 (correct), 1:1(0) ack 2560 win 1024
1210270129.749294 IP (tos 0x0, ttl 64, id 65257, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 2560:3072(512) ack 1 win 5840
1210270129.755196 IP (tos 0x0, ttl 100, id 47, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6734 (correct), 1:1(0) ack 3072 win 1024
1210270129.755227 IP (tos 0x0, ttl 64, id 65258, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.53527 > 192.168.200.150.9100: . 3584:4096(512) ack 1 win 5840
1210270130.453997 IP (tos 0x0, ttl 100, id 48, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.53527: ., cksum 0x6734 (correct), 1:1(0) ack 3072 win 1024

--------------090901050407010403020208--
