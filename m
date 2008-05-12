From: "Damon L. Chesser" <damon@damtek.com>
Subject: Re: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Mon, 12 May 2008 09:44:41 -0400
Message-ID: <482849C9.30905@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi> <4823437D.20005@damtek.com> <Pine.LNX.4.64.0805082336440.31776@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805120859470.1041@wrl-59.cs.helsinki.fi> <4828279C.3010102@damtek.com> <Pine.LNX.4.64.0805121419330.1888@wrl-59.cs.helsinki.fi> <4828304F.4040908@damtek.com> <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090908040709000302020606"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from damtek.com ([72.172.134.65]:38406 "EHLO damtek.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbYELNon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 09:44:43 -0400
In-Reply-To: <Pine.LNX.4.64.0805121503280.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090908040709000302020606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Ilpo Järvinen wrote:
> On Mon, 12 May 2008, Damon L. Chesser wrote:
>
>   
>> I ran the first patch and received this error:
>>
>> root@dam-main:/usr/src/linux-2.6.24.1# patch -p1 < ../1st_frto_patch.diff
>> patching file net/ipv4/tcp_input.c
>> patch: **** malformed patch at line 17: @@ -1685,6 +1683,10 @@ static inline
>> void tcp_reset_reno_sack(struct tcp_sock *tp)
>>
>> root@dam-main:/usr/src/linux-2.6.24.1#
>>
>> below is the text of the patch.diff I have:
>>     
>
> I suppose there was some space-vs-tab or additional-line-break added 
> issue while you saved it. Please try to save from the attached files 
> instead, it should keep the original formatting, they work as is with 
> patch -p1 (no need to cut anything). I tried them into 2.6.24.1 and both 
> of those should apply, though with some fuzz.
>
> --
>  i.
Ilpo,

I applied the patches in order, no errors on that.  I compiled a stock 
2.4.24-1 kernel with the patches, I saw no errors there.

booted into new kernel, printed with tcp_frto=0.  set tcp_frto =2, 
restarted the network (is this required, or is this a dynamic setting?), 
printed from OO document.  No joy.  tcpdump log attached (almost 15 min. 
worth of data)

If you want, I can re-compile and double check for any compilation 
errors, however, if there were any, it was not sever enough to stop the 
compilation.

-- 
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser


--------------090908040709000302020606
Content-Type: text/plain;
 name="frtoprob4.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="frtoprob4.txt"

1210598636.849859 arp who-has 192.168.200.150 tell 192.168.200.15
1210598636.851863 arp reply 192.168.200.150 is-at 00:0e:3b:00:3a:75
1210598636.851898 IP (tos 0x0, ttl 64, id 23930, offset 0, flags [DF], proto TCP (6), length 60) 192.168.200.15.49841 > 192.168.200.150.9100: S, cksum 0xa9c2 (correct), 834442554:834442554(0) win 5840 <mss 1460,sackOK,timestamp 116800 0,nop,wscale 7>
1210598636.855444 IP (tos 0x0, ttl 100, id 105, offset 0, flags [none], proto TCP (6), length 44) 192.168.200.150.9100 > 192.168.200.15.49841: S, cksum 0x0e99 (correct), 134529024:134529024(0) ack 834442555 win 1024 <mss 1024>
1210598636.855514 IP (tos 0x0, ttl 64, id 23931, offset 0, flags [DF], proto TCP (6), length 40) 192.168.200.15.49841 > 192.168.200.150.9100: ., cksum 0x11d2 (correct), 1:1(0) ack 1 win 5840
1210598637.996507 IP (tos 0x0, ttl 64, id 23932, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 1:513(512) ack 1 win 5840
1210598637.996532 IP (tos 0x0, ttl 64, id 23933, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 513:1025(512) ack 1 win 5840
1210598638.001927 IP (tos 0x0, ttl 100, id 106, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x22a2 (correct), 1:1(0) ack 513 win 1024
1210598638.001975 IP (tos 0x0, ttl 64, id 23934, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 1025:1537(512) ack 1 win 5840
1210598638.006423 IP (tos 0x0, ttl 100, id 107, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x20a2 (correct), 1:1(0) ack 1025 win 1024
1210598638.006473 IP (tos 0x0, ttl 64, id 23935, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 1537:2049(512) ack 1 win 5840
1210598638.011175 IP (tos 0x0, ttl 100, id 108, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x1ea2 (correct), 1:1(0) ack 1537 win 1024
1210598638.011229 IP (tos 0x0, ttl 64, id 23936, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 2049:2561(512) ack 1 win 5840
1210598638.015937 IP (tos 0x0, ttl 100, id 109, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x1ca2 (correct), 1:1(0) ack 2049 win 1024
1210598638.015965 IP (tos 0x0, ttl 64, id 23937, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 2561:3073(512) ack 1 win 5840
1210598638.022556 IP (tos 0x0, ttl 100, id 110, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x1aa2 (correct), 1:1(0) ack 2561 win 1024
1210598638.022576 IP (tos 0x0, ttl 64, id 23938, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 3073:3585(512) ack 1 win 5840
1210598638.025960 IP (tos 0x0, ttl 100, id 111, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x18a2 (correct), 1:1(0) ack 3073 win 1024
1210598638.025984 IP (tos 0x0, ttl 64, id 23939, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 3585:4097(512) ack 1 win 5840
1210598638.030182 IP (tos 0x0, ttl 100, id 112, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x16a2 (correct), 1:1(0) ack 3585 win 1024
1210598638.030205 IP (tos 0x0, ttl 64, id 23940, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 4097:4609(512) ack 1 win 5840
1210598638.034514 IP (tos 0x0, ttl 100, id 113, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x14a2 (correct), 1:1(0) ack 4097 win 1024
1210598638.034565 IP (tos 0x0, ttl 64, id 23941, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 4609:5121(512) ack 1 win 5840
1210598638.040023 IP (tos 0x0, ttl 100, id 114, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x12a2 (correct), 1:1(0) ack 4609 win 1024
1210598638.040071 IP (tos 0x0, ttl 64, id 23942, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 5121:5633(512) ack 1 win 5840
1210598638.044494 IP (tos 0x0, ttl 100, id 115, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x10a2 (correct), 1:1(0) ack 5121 win 1024
1210598638.044538 IP (tos 0x0, ttl 64, id 23943, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 5633:6145(512) ack 1 win 5840
1210598638.048656 IP (tos 0x0, ttl 100, id 116, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x0ea2 (correct), 1:1(0) ack 5633 win 1024
1210598638.048683 IP (tos 0x0, ttl 64, id 23944, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 6145:6657(512) ack 1 win 5840
1210598638.052850 IP (tos 0x0, ttl 100, id 117, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x0ca2 (correct), 1:1(0) ack 6145 win 1024
1210598638.052863 IP (tos 0x0, ttl 64, id 23945, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 6657:7169(512) ack 1 win 5840
1210598638.059816 IP (tos 0x0, ttl 100, id 118, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x0aa2 (correct), 1:1(0) ack 6657 win 1024
1210598638.059843 IP (tos 0x0, ttl 64, id 23946, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 7169:7681(512) ack 1 win 5840
1210598638.064378 IP (tos 0x0, ttl 100, id 119, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x08a2 (correct), 1:1(0) ack 7169 win 1024
1210598638.064420 IP (tos 0x0, ttl 64, id 23947, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 7681:8193(512) ack 1 win 5840
1210598638.069040 IP (tos 0x0, ttl 100, id 120, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x06a2 (correct), 1:1(0) ack 7681 win 1024
1210598638.069090 IP (tos 0x0, ttl 64, id 23948, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 8193:8705(512) ack 1 win 5840
1210598638.073544 IP (tos 0x0, ttl 100, id 121, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x04a2 (correct), 1:1(0) ack 8193 win 1024
1210598638.073592 IP (tos 0x0, ttl 64, id 23949, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 8705:9217(512) ack 1 win 5840
1210598638.080437 IP (tos 0x0, ttl 100, id 122, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x02a2 (correct), 1:1(0) ack 8705 win 1024
1210598638.080461 IP (tos 0x0, ttl 64, id 23950, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 9217:9729(512) ack 1 win 5840
1210598638.084244 IP (tos 0x0, ttl 100, id 123, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0x00a2 (correct), 1:1(0) ack 9217 win 1024
1210598638.084258 IP (tos 0x0, ttl 64, id 23951, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 9729:10241(512) ack 1 win 5840
1210598638.087992 IP (tos 0x0, ttl 100, id 124, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xfea1 (correct), 1:1(0) ack 9729 win 1024
1210598638.088014 IP (tos 0x0, ttl 64, id 23952, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 10241:10753(512) ack 1 win 5840
1210598638.092925 IP (tos 0x0, ttl 100, id 125, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xfca1 (correct), 1:1(0) ack 10241 win 1024
1210598638.092943 IP (tos 0x0, ttl 64, id 23953, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 10753:11265(512) ack 1 win 5840
1210598638.095674 IP (tos 0x0, ttl 100, id 126, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xfca1 (correct), 1:1(0) ack 10753 win 512
1210598638.098915 IP (tos 0x0, ttl 100, id 127, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xfaa1 (correct), 1:1(0) ack 11265 win 512
1210598638.098939 IP (tos 0x0, ttl 64, id 23954, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 11265:11777(512) ack 1 win 5840
1210598638.102729 IP (tos 0x0, ttl 100, id 128, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xf8a1 (correct), 1:1(0) ack 11777 win 512
1210598638.102741 IP (tos 0x0, ttl 64, id 23955, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 11777:12289(512) ack 1 win 5840
1210598638.309935 IP (tos 0x0, ttl 64, id 23956, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 11777:12289(512) ack 1 win 5840
1210598638.334007 IP (tos 0x0, ttl 100, id 129, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xf6a1 (correct), 1:1(0) ack 12289 win 512
1210598638.334054 IP (tos 0x0, ttl 64, id 23957, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 12289:12801(512) ack 1 win 5840
1210598638.556548 IP (tos 0x0, ttl 100, id 130, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xf2a1 (correct), 1:1(0) ack 12801 win 1024
1210598638.556597 IP (tos 0x0, ttl 64, id 23958, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 12801:13313(512) ack 1 win 5840
1210598638.556606 IP (tos 0x0, ttl 64, id 23959, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 13313:13825(512) ack 1 win 5840
1210598638.567069 IP (tos 0x0, ttl 100, id 131, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xf0a1 (correct), 1:1(0) ack 13313 win 1024
1210598638.567100 IP (tos 0x0, ttl 64, id 23960, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 13825:14337(512) ack 1 win 5840
1210598638.571060 IP (tos 0x0, ttl 100, id 132, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xeea1 (correct), 1:1(0) ack 13825 win 1024
1210598638.571083 IP (tos 0x0, ttl 64, id 23961, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 14337:14849(512) ack 1 win 5840
1210598638.574242 IP (tos 0x0, ttl 100, id 133, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xeea1 (correct), 1:1(0) ack 14337 win 512
1210598638.578004 IP (tos 0x0, ttl 100, id 134, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xeca1 (correct), 1:1(0) ack 14849 win 512
1210598638.578026 IP (tos 0x0, ttl 64, id 23962, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 14849:15361(512) ack 1 win 5840
1210598638.583733 IP (tos 0x0, ttl 100, id 135, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xeaa1 (correct), 1:1(0) ack 15361 win 512
1210598638.583754 IP (tos 0x0, ttl 64, id 23963, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 15361:15873(512) ack 1 win 5840
1210598638.587994 IP (tos 0x0, ttl 100, id 136, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xe8a1 (correct), 1:1(0) ack 15873 win 512
1210598638.588008 IP (tos 0x0, ttl 64, id 23964, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 15873:16385(512) ack 1 win 5840
1210598638.592083 IP (tos 0x0, ttl 100, id 137, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xe6a1 (correct), 1:1(0) ack 16385 win 512
1210598638.592106 IP (tos 0x0, ttl 64, id 23965, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 16385:16897(512) ack 1 win 5840
1210598638.596289 IP (tos 0x0, ttl 100, id 138, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xe4a1 (correct), 1:1(0) ack 16897 win 512
1210598638.596301 IP (tos 0x0, ttl 64, id 23966, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 16897:17409(512) ack 1 win 5840
1210598638.601744 IP (tos 0x0, ttl 100, id 139, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xe2a1 (correct), 1:1(0) ack 17409 win 512
1210598638.601766 IP (tos 0x0, ttl 64, id 23967, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 17409:17921(512) ack 1 win 5840
1210598638.605859 IP (tos 0x0, ttl 100, id 140, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xe0a1 (correct), 1:1(0) ack 17921 win 512
1210598638.605872 IP (tos 0x0, ttl 64, id 23968, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 17921:18433(512) ack 1 win 5840
1210598638.611944 IP (tos 0x0, ttl 100, id 141, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xdca1 (correct), 1:1(0) ack 18433 win 1024
1210598638.611996 IP (tos 0x0, ttl 64, id 23969, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 18433:18945(512) ack 1 win 5840
1210598638.612006 IP (tos 0x0, ttl 64, id 23970, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 18945:19457(512) ack 1 win 5840
1210598638.626765 IP (tos 0x0, ttl 100, id 142, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xdaa1 (correct), 1:1(0) ack 18945 win 1024
1210598638.626800 IP (tos 0x0, ttl 64, id 23971, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 19457:19969(512) ack 1 win 5840
1210598638.849968 IP (tos 0x0, ttl 64, id 23972, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 18945:19457(512) ack 1 win 5840
1210598638.853907 IP (tos 0x0, ttl 100, id 143, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd8a1 (correct), 1:1(0) ack 19457 win 1024
1210598638.853937 IP (tos 0x0, ttl 64, id 23973, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 19969:20481(512) ack 1 win 5840
1210598639.301994 IP (tos 0x0, ttl 64, id 23974, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 19457:19969(512) ack 1 win 5840
1210598639.307911 IP (tos 0x0, ttl 100, id 144, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd6a1 (correct), 1:1(0) ack 19969 win 1024
1210598639.307957 IP (tos 0x0, ttl 64, id 23975, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 20481:20993(512) ack 1 win 5840
1210598640.002669 IP (tos 0x0, ttl 100, id 145, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd6a1 (correct), 1:1(0) ack 19969 win 1024
1210598640.002718 IP (tos 0x0, ttl 64, id 23976, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 19969:20481(512) ack 1 win 5840
1210598640.009222 IP (tos 0x0, ttl 100, id 146, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd4a1 (correct), 1:1(0) ack 20481 win 1024
1210598640.009277 IP (tos 0x0, ttl 64, id 23977, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 20993:21505(512) ack 1 win 5840
1210598640.708995 IP (tos 0x0, ttl 100, id 147, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd4a1 (correct), 1:1(0) ack 20481 win 1024
1210598640.901981 IP (tos 0x0, ttl 64, id 23978, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 20481:20993(512) ack 1 win 5840
1210598640.908117 IP (tos 0x0, ttl 100, id 148, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd2a1 (correct), 1:1(0) ack 20993 win 1024
1210598640.908175 IP (tos 0x0, ttl 64, id 23979, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 21505:22017(512) ack 1 win 5840
1210598641.602725 IP (tos 0x0, ttl 100, id 149, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd2a1 (correct), 1:1(0) ack 20993 win 1024
1210598641.602773 IP (tos 0x0, ttl 64, id 23980, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 20993:21505(512) ack 1 win 5840
1210598641.609275 IP (tos 0x0, ttl 100, id 150, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd0a1 (correct), 1:1(0) ack 21505 win 1024
1210598641.609292 IP (tos 0x0, ttl 64, id 23981, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 22017:22529(512) ack 1 win 5840
1210598642.308931 IP (tos 0x0, ttl 100, id 151, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xd0a1 (correct), 1:1(0) ack 21505 win 1024
1210598643.398246 IP (tos 0x0, ttl 64, id 23982, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 21505:22017(512) ack 1 win 5840
1210598643.402305 IP (tos 0x0, ttl 100, id 152, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcea1 (correct), 1:1(0) ack 22017 win 1024
1210598643.402359 IP (tos 0x0, ttl 64, id 23983, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 22529:23041(512) ack 1 win 5840
1210598644.101612 IP (tos 0x0, ttl 100, id 153, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcea1 (correct), 1:1(0) ack 22017 win 1024
1210598644.101661 IP (tos 0x0, ttl 64, id 23984, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 22017:22529(512) ack 1 win 5840
1210598644.108168 IP (tos 0x0, ttl 100, id 154, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcca1 (correct), 1:1(0) ack 22529 win 1024
1210598644.108222 IP (tos 0x0, ttl 64, id 23985, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 23041:23553(512) ack 1 win 5840
1210598644.802907 IP (tos 0x0, ttl 100, id 155, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcca1 (correct), 1:1(0) ack 22529 win 1024
1210598647.690507 IP (tos 0x0, ttl 64, id 23986, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 22529:23041(512) ack 1 win 5840
1210598647.694424 IP (tos 0x0, ttl 100, id 159, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcaa1 (correct), 1:1(0) ack 23041 win 1024
1210598647.694464 IP (tos 0x0, ttl 64, id 23987, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 23553:24065(512) ack 1 win 5840
1210598648.393212 IP (tos 0x0, ttl 100, id 160, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xcaa1 (correct), 1:1(0) ack 23041 win 1024
1210598648.393259 IP (tos 0x0, ttl 64, id 23988, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 23041:23553(512) ack 1 win 5840
1210598648.399741 IP (tos 0x0, ttl 100, id 161, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc8a1 (correct), 1:1(0) ack 23553 win 1024
1210598648.399777 IP (tos 0x0, ttl 64, id 23989, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 24065:24577(512) ack 1 win 5840
1210598649.094481 IP (tos 0x0, ttl 100, id 162, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc8a1 (correct), 1:1(0) ack 23553 win 1024
1210598655.566968 IP (tos 0x0, ttl 64, id 23990, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 23553:24065(512) ack 1 win 5840
1210598655.570872 IP (tos 0x0, ttl 100, id 163, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc6a1 (correct), 1:1(0) ack 24065 win 1024
1210598655.570903 IP (tos 0x0, ttl 64, id 23991, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 24577:25089(512) ack 1 win 5840
1210598656.270124 IP (tos 0x0, ttl 100, id 164, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc6a1 (correct), 1:1(0) ack 24065 win 1024
1210598656.270168 IP (tos 0x0, ttl 64, id 23992, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 24065:24577(512) ack 1 win 5840
1210598656.276663 IP (tos 0x0, ttl 100, id 165, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc4a1 (correct), 1:1(0) ack 24577 win 1024
1210598656.276680 IP (tos 0x0, ttl 64, id 23993, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 25089:25601(512) ack 1 win 5840
1210598656.971404 IP (tos 0x0, ttl 100, id 166, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc4a1 (correct), 1:1(0) ack 24577 win 1024
1210598670.611871 IP (tos 0x0, ttl 64, id 23994, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 24577:25089(512) ack 1 win 5840
1210598670.617139 IP (tos 0x0, ttl 100, id 167, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc2a1 (correct), 1:1(0) ack 25089 win 1024
1210598670.617188 IP (tos 0x0, ttl 64, id 23995, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 25601:26113(512) ack 1 win 5840
1210598671.312854 IP (tos 0x0, ttl 100, id 168, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc2a1 (correct), 1:1(0) ack 25089 win 1024
1210598671.312899 IP (tos 0x0, ttl 64, id 23996, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 25089:25601(512) ack 1 win 5840
1210598671.319408 IP (tos 0x0, ttl 100, id 169, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc0a1 (correct), 1:1(0) ack 25601 win 1024
1210598671.319424 IP (tos 0x0, ttl 64, id 23997, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 26113:26625(512) ack 1 win 5840
1210598672.019199 IP (tos 0x0, ttl 100, id 170, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xc0a1 (correct), 1:1(0) ack 25601 win 1024
1210598699.989635 IP (tos 0x0, ttl 64, id 23998, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 25601:26113(512) ack 1 win 5840
1210598699.993560 IP (tos 0x0, ttl 100, id 171, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbea1 (correct), 1:1(0) ack 26113 win 1024
1210598699.993590 IP (tos 0x0, ttl 64, id 23999, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 26625:27137(512) ack 1 win 5840
1210598700.692114 IP (tos 0x0, ttl 100, id 172, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbea1 (correct), 1:1(0) ack 26113 win 1024
1210598700.692161 IP (tos 0x0, ttl 64, id 24000, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 26113:26625(512) ack 1 win 5840
1210598700.698643 IP (tos 0x0, ttl 100, id 173, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbca1 (correct), 1:1(0) ack 26625 win 1024
1210598700.698660 IP (tos 0x0, ttl 64, id 24001, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 27137:27649(512) ack 1 win 5840
1210598701.398325 IP (tos 0x0, ttl 100, id 174, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbca1 (correct), 1:1(0) ack 26625 win 1024
1210598758.045115 IP (tos 0x0, ttl 64, id 24002, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 26625:27137(512) ack 1 win 5840
1210598758.049665 IP (tos 0x0, ttl 100, id 178, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbaa1 (correct), 1:1(0) ack 27137 win 1024
1210598758.049697 IP (tos 0x0, ttl 64, id 24003, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 27649:28161(512) ack 1 win 5840
1210598758.749359 IP (tos 0x0, ttl 100, id 179, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xbaa1 (correct), 1:1(0) ack 27137 win 1024
1210598758.749404 IP (tos 0x0, ttl 64, id 24004, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 27137:27649(512) ack 1 win 5840
1210598758.755872 IP (tos 0x0, ttl 100, id 180, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb8a1 (correct), 1:1(0) ack 27649 win 1024
1210598758.755889 IP (tos 0x0, ttl 64, id 24005, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 28161:28673(512) ack 1 win 5840
1210598759.450606 IP (tos 0x0, ttl 100, id 181, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb8a1 (correct), 1:1(0) ack 27649 win 1024
1210598873.448031 IP (tos 0x0, ttl 64, id 24006, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 27649:28161(512) ack 1 win 5840
1210598873.452984 IP (tos 0x0, ttl 100, id 185, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb6a1 (correct), 1:1(0) ack 28161 win 1024
1210598873.453010 IP (tos 0x0, ttl 64, id 24007, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 28673:29185(512) ack 1 win 5840
1210598874.147736 IP (tos 0x0, ttl 100, id 186, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb6a1 (correct), 1:1(0) ack 28161 win 1024
1210598874.147781 IP (tos 0x0, ttl 64, id 24008, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 28161:28673(512) ack 1 win 5840
1210598874.154257 IP (tos 0x0, ttl 100, id 187, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb4a1 (correct), 1:1(0) ack 28673 win 1024
1210598874.154275 IP (tos 0x0, ttl 64, id 24009, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 29185:29697(512) ack 1 win 5840
1210598874.848987 IP (tos 0x0, ttl 100, id 188, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb4a1 (correct), 1:1(0) ack 28673 win 1024
1210598994.159267 IP (tos 0x0, ttl 64, id 24010, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 28673:29185(512) ack 1 win 5840
1210598994.165203 IP (tos 0x0, ttl 100, id 195, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb2a1 (correct), 1:1(0) ack 29185 win 1024
1210598994.165234 IP (tos 0x0, ttl 64, id 24011, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 29697:30209(512) ack 1 win 5840
1210598994.864884 IP (tos 0x0, ttl 100, id 196, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb2a1 (correct), 1:1(0) ack 29185 win 1024
1210598994.864928 IP (tos 0x0, ttl 64, id 24012, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 29185:29697(512) ack 1 win 5840
1210598994.871533 IP (tos 0x0, ttl 100, id 197, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb0a1 (correct), 1:1(0) ack 29697 win 1024
1210598994.871549 IP (tos 0x0, ttl 64, id 24013, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 30209:30721(512) ack 1 win 5840
1210598995.566158 IP (tos 0x0, ttl 100, id 198, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xb0a1 (correct), 1:1(0) ack 29697 win 1024
1210599114.878503 IP (tos 0x0, ttl 64, id 24014, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 29697:30209(512) ack 1 win 5840
1210599114.882513 IP (tos 0x0, ttl 100, id 202, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaea1 (correct), 1:1(0) ack 30209 win 1024
1210599114.882546 IP (tos 0x0, ttl 64, id 24015, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 30721:31233(512) ack 1 win 5840
1210599115.577094 IP (tos 0x0, ttl 100, id 203, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaea1 (correct), 1:1(0) ack 30209 win 1024
1210599115.577141 IP (tos 0x0, ttl 64, id 24016, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 30209:30721(512) ack 1 win 5840
1210599115.583636 IP (tos 0x0, ttl 100, id 204, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaca1 (correct), 1:1(0) ack 30721 win 1024
1210599115.583653 IP (tos 0x0, ttl 64, id 24017, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 31233:31745(512) ack 1 win 5840
1210599116.278385 IP (tos 0x0, ttl 100, id 205, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaca1 (correct), 1:1(0) ack 30721 win 1024
1210599235.589761 IP (tos 0x0, ttl 64, id 24018, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 30721:31233(512) ack 1 win 5840
1210599235.594556 IP (tos 0x0, ttl 100, id 212, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaaa1 (correct), 1:1(0) ack 31233 win 1024
1210599235.594595 IP (tos 0x0, ttl 64, id 24019, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 31745:32257(512) ack 1 win 5840
1210599236.289314 IP (tos 0x0, ttl 100, id 213, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xaaa1 (correct), 1:1(0) ack 31233 win 1024
1210599236.289361 IP (tos 0x0, ttl 64, id 24020, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 31233:31745(512) ack 1 win 5840
1210599236.295847 IP (tos 0x0, ttl 100, id 214, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa8a1 (correct), 1:1(0) ack 31745 win 1024
1210599236.295865 IP (tos 0x0, ttl 64, id 24021, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 32257:32769(512) ack 1 win 5840
1210599236.990579 IP (tos 0x0, ttl 100, id 215, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa8a1 (correct), 1:1(0) ack 31745 win 1024
1210599356.300987 IP (tos 0x0, ttl 64, id 24022, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 31745:32257(512) ack 1 win 5840
1210599356.306860 IP (tos 0x0, ttl 100, id 219, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa6a1 (correct), 1:1(0) ack 32257 win 1024
1210599356.306914 IP (tos 0x0, ttl 64, id 24023, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: . 32769:33281(512) ack 1 win 5840
1210599357.001550 IP (tos 0x0, ttl 100, id 220, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa6a1 (correct), 1:1(0) ack 32257 win 1024
1210599357.001597 IP (tos 0x0, ttl 64, id 24024, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 32257:32769(512) ack 1 win 5840
1210599357.008325 IP (tos 0x0, ttl 100, id 221, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa4a1 (correct), 1:1(0) ack 32769 win 1024
1210599357.008344 IP (tos 0x0, ttl 64, id 24025, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.49841 > 192.168.200.150.9100: P 33281:33793(512) ack 1 win 5840
1210599357.702816 IP (tos 0x0, ttl 100, id 222, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.49841: ., cksum 0xa4a1 (correct), 1:1(0) ack 32769 win 1024

--------------090908040709000302020606--
