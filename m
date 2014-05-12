From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Socket receives packet to multicast group to which it was not
 joined since kernel 3.13.10-1
Date: Mon, 12 May 2014 10:18:02 -0700
Message-ID: <1399915082.7973.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5370F8EB.2070009@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:40012 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759223AbaELRSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 13:18:05 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so8934072pab.17
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 10:18:04 -0700 (PDT)
In-Reply-To: <5370F8EB.2070009@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 20:38 +0400, Yurij M. Plotnikov wrote:
> On kernel 3.13.10-1 I see that socket joined to one multicast group 
> receives packets to another multicast address. That can be reproduced by 
> the following example:
> 
> 1. socket(DGRAM) -> 3
> 2. bind(3, 0.0.0.0:12345) -> 0
> 3. setsockopt(3, IP_MULTICAST_IF, {224.168.2.9, 7}) -> 0
> // "7" is correct interface index
> 
> 4. Send packet from peer host to 224.168.2.9:12345
> 5. poll({3, POLLIN}) -> 1
> 6. recv(3) -> <data_length>
> 
> 5. Send packet from peer host to 225.168.2.9:12345
> // Note that the address is not the same!
> 6. poll({3, POLLIN}) -> 1
> 7. recv(3) -> <data_length>
> 
> I checked kernel 3.12.6-2, there is no such problem. I have placed 
> simple C-program in attachment to reproduce the behaviour. It should be 
> called:
> ./mult_recv <mcast_address> <interface index> i.e. in example above:
> ./mult_recv 224.168.2.9 7

I suspect problem came with commit
421b3885bf6d56391297844f43fb7154a6396e12
("udp: ipv4: Add udp early demux")

Is that better if you try :

echo 0 >/proc/sys/net/ipv4/ip_early_demux
