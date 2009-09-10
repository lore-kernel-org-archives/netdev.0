From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Wed, 9 Sep 2009 23:06:13 -0700 (PDT)
Message-ID: <204967.7557.qm@web111613.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>  <1252376168.5244.11.camel@dogo.mojatatu.com>  <313388.35529.qm@web111617.mail.gq1.yahoo.com> <1252534266.4119.5.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n7.bullet.mail.ac4.yahoo.com ([76.13.13.235]:31155 "HELO
	n7.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755043AbZIJGGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 02:06:12 -0400
In-Reply-To: <1252534266.4119.5.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>> After run 'tcpdump -i wlan1 -e', I can not capture any packets.

>Could it be related to the wireless driver?
Maybe. I will check it.

>Here's something i tried on my laptop
....
>

I tried your example.

-on window1  'ping 127.0.0.2'
....
2616 packets transmitted, 0 received, 100% packet loss

-on window2  'tcpdump -n -i eth0 -e' , i see
....
10:15:06.314420 00:23:cd:af:d0:74 > 00:23:cd:af:ec:da, ethertype IPv4 (0x0800), length 98: 127.0.0.2 > 127.0.0.2: ICMP echo request, id 17419, seq 234, length 64
....

-on window3  'tcpdump -i lo -e'
....
10:15:37.332527 00:23:cd:af:d0:74 (oui Unknown) > 00:23:cd:af:ec:da (oui Unknown), ethertype IPv4 (0x0800), length 98: 127.0.0.2 > 127.0.0.2: ICMP echo request, id 17419, seq 265, length 64
....

It seems that I modify the dst MAC, src MAC of the packets,  then transmit to 'lo'  and  mirror the packects to 'eth0'.  (On 'lo',  '2616 packets transmitted, 0 received, 100% packet loss' .)  How to let 'lo' receive the packets?

But I want to only modify the dst MAC, src MAC of the mirroring packets, transmit them to next hop. (not modify the dst,src MAC of the packets to 'lo').  What should I do?

When I change 'lo' to 'eth1' (or wlan1 ...), node A will have two paths (A-B-C, A-D-C) to transmit the "same"(IP header, data)  packets to node C simultaneously.


regards,
wu



      

