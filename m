From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Sat, 22 Sep 2012 07:26:32 +0100
Message-ID: <505D5A18.2080507@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com> <1347979239.26523.267.camel@edumazet-glaptop> <5059E40C.4070607@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50232 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab2IVG0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 02:26:36 -0400
Received: by wibhi8 with SMTP id hi8so2924281wib.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 23:26:34 -0700 (PDT)
In-Reply-To: <5059E40C.4070607@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I guess you network developer folks are either very busy or this 
regression is proving a bit troublesome to identify, so I've opened a 
bugzilla report to keep track of it. The report number is 47761.

Chris

On 09/19/12 16:26, Chris Clayton wrote:
>>
>> It would help to have some traffic sample, maybe.
>>
>> Especially if the problem is not easily reproductible for us.
>>
>
> OK, I've used an netsniff-ng to capture the traffic on all interfaces on
> the host (that would be tap0 and eth0, I guess) whilst attempting to
> ping the router from the WinXP KVM client. The result is a pcap file
> that I processed with tcpdump to produce:
>
> reading from file net-trace.pcap, link-type EN10MB (Ethernet)
> 14:56:31.406336 ARP, Request who-has 192.168.200.254 tell 192.168.200.1,
> length 28
>          0x0000:  0001 0800 0604 0001 5254 0c3b 1728 c0a8
>          0x0010:  c801 0000 0000 0000 c0a8 c8fe
> 14:56:31.406357 ARP, Reply 192.168.200.254 is-at 46:83:93:8f:f0:7e,
> length 28
>          0x0000:  0001 0800 0604 0002 4683 938f f07e c0a8
>          0x0010:  c8fe 5254 0c3b 1728 c0a8 c801
> 14:56:31.406534 IP 192.168.200.1 > 192.168.0.1: ICMP echo request, id
> 512, seq 4352, length 40
>          0x0000:  4500 003c 0195 0000 8001 efd8 c0a8 c801
>          0x0010:  c0a8 0001 0800 3a5c 0200 1100 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:31.406566 ARP, Request who-has 192.168.0.1 tell 192.168.0.40,
> length 28
>          0x0000:  0001 0800 0604 0001 5c9a d85c 6331 c0a8
>          0x0010:  0028 0000 0000 0000 c0a8 0001
> 14:56:31.410830 ARP, Reply 192.168.0.1 is-at 00:1f:33:80:09:44, length 46
>          0x0000:  0001 0800 0604 0002 001f 3380 0944 c0a8
>          0x0010:  0001 5c9a d85c 6331 c0a8 0028 c0a8 0001
>          0x0020:  e000 0001 1164 ee9b 0000 0000 4500
> 14:56:31.410851 IP 192.168.0.40 > 192.168.0.1: ICMP echo request, id
> 512, seq 4352, length 40
>          0x0000:  4500 003c 0195 0000 7f01 b8b2 c0a8 0028
>          0x0010:  c0a8 0001 0800 3a5c 0200 1100 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:31.414474 IP 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512,
> seq 4352, length 40
>          0x0000:  4500 003c cf4f 0000 ff01 6af7 c0a8 0001
>          0x0010:  c0a8 0028 0000 425c 0200 1100 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:36.404781 ARP, Request who-has 192.168.0.40 tell 192.168.0.1,
> length 46
>          0x0000:  0001 0800 0604 0001 001f 3380 0944 c0a8
>          0x0010:  0001 0000 0000 0000 c0a8 0028 c0a8 0001
>          0x0020:  c0a8 0028 0000 425c 0200 1100 6162
> 14:56:36.404806 ARP, Reply 192.168.0.40 is-at 5c:9a:d8:5c:63:31, length 28
>          0x0000:  0001 0800 0604 0002 5c9a d85c 6331 c0a8
>          0x0010:  0028 001f 3380 0944 c0a8 0001
> 14:56:36.689750 IP 192.168.200.1 > 192.168.0.1: ICMP echo request, id
> 512, seq 4608, length 40
>          0x0000:  4500 003c 0196 0000 8001 efd7 c0a8 c801
>          0x0010:  c0a8 0001 0800 395c 0200 1200 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:36.689774 IP 192.168.0.40 > 192.168.0.1: ICMP echo request, id
> 512, seq 4608, length 40
>          0x0000:  4500 003c 0196 0000 7f01 b8b1 c0a8 0028
>          0x0010:  c0a8 0001 0800 395c 0200 1200 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:36.693330 IP 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512,
> seq 4608, length 40
>          0x0000:  4500 003c cf50 0000 ff01 6af6 c0a8 0001
>          0x0010:  c0a8 0028 0000 415c 0200 1200 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:42.189424 IP 192.168.200.1 > 192.168.0.1: ICMP echo request, id
> 512, seq 4864, length 40
>          0x0000:  4500 003c 0197 0000 8001 efd6 c0a8 c801
>          0x0010:  c0a8 0001 0800 385c 0200 1300 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:42.189447 IP 192.168.0.40 > 192.168.0.1: ICMP echo request, id
> 512, seq 4864, length 40
>          0x0000:  4500 003c 0197 0000 7f01 b8b0 c0a8 0028
>          0x0010:  c0a8 0001 0800 385c 0200 1300 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:42.193029 IP 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512,
> seq 4864, length 40
>          0x0000:  4500 003c cf51 0000 ff01 6af5 c0a8 0001
>          0x0010:  c0a8 0028 0000 405c 0200 1300 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:47.689414 IP 192.168.200.1 > 192.168.0.1: ICMP echo request, id
> 512, seq 5120, length 40
>          0x0000:  4500 003c 0198 0000 8001 efd5 c0a8 c801
>          0x0010:  c0a8 0001 0800 375c 0200 1400 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:47.689439 IP 192.168.0.40 > 192.168.0.1: ICMP echo request, id
> 512, seq 5120, length 40
>          0x0000:  4500 003c 0198 0000 7f01 b8af c0a8 0028
>          0x0010:  c0a8 0001 0800 375c 0200 1400 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
> 14:56:47.693661 IP 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512,
> seq 5120, length 40
>          0x0000:  4500 003c cf52 0000 ff01 6af4 c0a8 0001
>          0x0010:  c0a8 0028 0000 3f5c 0200 1400 6162 6364
>          0x0020:  6566 6768 696a 6b6c 6d6e 6f70 7172 7374
>          0x0030:  7576 7761 6263 6465 6667 6869
>
> Is this what you asked for?
>
> Chris
>
