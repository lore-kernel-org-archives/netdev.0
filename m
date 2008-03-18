From: Patrick McHardy <kaber@trash.net>
Subject: Re: interface based conntrack entry
Date: Tue, 18 Mar 2008 12:49:30 +0100
Message-ID: <47DFAC4A.9070501@trash.net>
References: <CAC6870A2B8FE846AD24D7E75B05F90A3F1960@moe.nextone.local> <1C6541574A2FC447B53A6B4522B678AF015A12C5@moe.nextone.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	Paritosh Tyagi <ptyagi@nextpointnetworks.com>
To: Sohan Shetty <sshetty@nextpointnetworks.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1C6541574A2FC447B53A6B4522B678AF015A12C5@moe.nextone.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sohan Shetty wrote:
> Forwarding query from Paritosh Tyagi to Netfilter mailing list.
> 
> 
> --------------------------------------------------------------------
> Hello,
> 
> We are using 2.6.18 version of the kernel and we have following issue related to conntrack module and Vlan interfaces.
> 
> 
> 
>       Ep1 (192.168.1.100)                   Eth1.100  (192.168.1.1)    (ip interface) 169.254.16.1
>        |-------------------------------------------|-------------------------------|
> 
>       Ep2 (192.168.1.100)                   Eth1.101  (192.168.1.1)    (ip interface) 169.254.16.2
>        |-------------------------------------------|-------------------------------|
> 
> 
>       Here, our box is connected to two distinct networks 192.168.1/24 via a different vlan. Our application is exposing the same ip address (192.168.1.1) on both the vlans. On eth1.100 internal ip address 169.254.16.1  is configured and on eth1.101 internal ip address 169.254.16.2 is configured. 
>      Ep1 and ep2 talk to 192.168.1.1 on the two vlans.
>      Iptables and arptables rules are added to map incoming/outgoing ip/arp packets on eth1.100 to/from 169.254.16.1 and on eth1.101 to/from 169.254.16.2. 
>  
>     The problem we are seeing is, that when an incoming packet comes in from ep1 a conntrack entry is created for 
> Proto=udp, srcip=192.168.1.100, dstip=192.168.1.1, sport=5060, dport=5060, this packet is DNAT'ed to 169.254.16.1  and our application receives it on the socket bound to that ip. However, when ep2 sends a packet, it seems that the conntrack entry matches it and the ip table NAT rule (which should map this packet to 169.254.16.2) is ignored and because of the 4-tuple match with existing udp conntrack entry, the packet is sent to 169.254.16.1. 
> 
>    Is there a patch to support the in-interface and out-interface or mark in the conntrack module? So, we can have two entries in there where the 4 tuple is the same only the interface is different? 

There is a patch to do something pretty similar:

http://candelatech.com/oss/conntrack_mark_with_ssyctl.patch

It allows to set default skb mark values per device and
uses those as additional key for conntrack lookups.
