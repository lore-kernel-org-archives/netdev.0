From: Alex <d77190@mail.ru>
Subject: Re: Bug 75571
Date: Fri, 06 Jun 2014 11:13:01 +0700
Message-ID: <1402027981.29664.16.camel@anpws>
References: <1401085231.1775.9.camel@anpws>
	 <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	 <1401870692.29664.1.camel@anpws>
	 <CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
	 <1401945732.29664.6.camel@anpws>
	 <CAHA+R7Mi-mBXWSytEtJhqEfjYQyrd9zae5GndYy3qmK=+_mk_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnat3.880.ru ([194.8.85.227]:14733 "EHLO stk-gw0.880.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750740AbaFFEMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 00:12:47 -0400
In-Reply-To: <CAHA+R7Mi-mBXWSytEtJhqEfjYQyrd9zae5GndYy3qmK=+_mk_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, e1000e should init dev->hard_header_len to ETH_LEN, which is 14.
> Plus IPv4 header len (20), it should be about 34. I don't understand why
> the ipip tunnel's hard_header_len is 148 in your case. It is only possible when
> there is no underlying interface, that is, LL_MAX_HEADER + sizeof(struct iphdr).
> 
> What do `ip -d link show` and `ip route show` say?

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT group default qlen 1000
    link/ether 00:15:17:28:a7:02 brd ff:ff:ff:ff:ff:ff

7: eth0.99@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP mode DEFAULT group default 
    link/ether 00:15:17:28:a7:02 brd ff:ff:ff:ff:ff:ff
    vlan protocol 802.1q id 99 <REORDER_HDR> 

84: tun4177: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc htb state
UNKNOWN mode DEFAULT group default 
    link/ipip 192.168.18.199 peer 192.168.18.17


192.168.18.199 is loopback address.

ip route show dev eth0.99
172.16.254.132/30  proto kernel  scope link  src 172.16.254.134
192.168.18.0/26 via 172.16.254.133  proto zebra
.... and about 200 networks received via BGP

ip route show dev tun4177
198.18.0.177  proto kernel  scope link  src 198.18.0.1
198.18.100.3 via 198.18.0.177  proto zebra  metric 17
.... and about 500 routes to hosts recieved via OSPF
