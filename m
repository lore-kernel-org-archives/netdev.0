From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 17:57:51 +0100
Message-ID: <1321549071.2751.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC2CA52.6020104@icdsoft.com>
	 <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com>
	 <20111116223330.08de9e52@asterix.rh> <4EC4C160.6010804@icdsoft.com>
	 <20111117111145.252924f5@asterix.rh>
	 <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117133724.59684d28@asterix.rh>
	 <1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111117144038.61b0525b@asterix.rh>
	 <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55927 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab1KQQ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 11:57:56 -0500
Received: by wyh11 with SMTP id 11so2249441wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 08:57:54 -0800 (PST)
In-Reply-To: <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some traces :

$ ping -c 3 213.254.248.147
PING 213.254.248.147 (213.254.248.147) 56(84) bytes of data.
>From 192.168.20.108: icmp_seq=1 Redirect Host(New nexthop: 192.168.20.254)
2011/10/17 17:55:56.827 64 bytes from 213.254.248.147: icmp_seq=1 ttl=55 time=10.4 ms
>From 192.168.20.108: icmp_seq=2 Redirect Host(New nexthop: 192.168.20.254)
2011/10/17 17:55:57.828 64 bytes from 213.254.248.147: icmp_seq=2 ttl=55 time=9.87 ms
>From 192.168.20.108: icmp_seq=3 Redirect Host(New nexthop: 192.168.20.254)
2011/10/17 17:55:58.829 64 bytes from 213.254.248.147: icmp_seq=3 ttl=55 time=10.2 ms

--- 213.254.248.147 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 9.871/10.198/10.478/0.275 ms
$ ip ro list cache match 213.254.248.147
213.254.248.147 from 192.168.20.110 via 192.168.20.108 dev vlan.103 
    cache  ipid 0x7187
213.254.248.147 from 192.168.20.110 via 192.168.20.254 dev vlan.103 
    cache <redirected>  ipid 0x7187
213.254.248.147 via 192.168.20.108 dev vlan.103  src 192.168.20.110 
    cache 

$ ip ro get 213.254.248.147
213.254.248.147 via 192.168.20.108 dev vlan.103  src 192.168.20.110 
    cache
