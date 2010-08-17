From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 07:35:28 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se> <1281953960.2524.23.camel@edumazet-laptop> <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2010, Thomas Habets wrote:
> Am I not allowed to add addresses to lo? That I've deconfigured this address 
> and rebooted the box to check if this matters.

It didn't help.

> I will re-check ethtool and Cisco router output for mismatches when it breaks 
> again to make sure that there's no change or errors counting up.

IPv6 is currently not working and it's still 1000 Full on both sides 
("show int GiX/Y" and "ethtool eth0").
No errors in "ethtool -S eth0" or "show int GiX/Y".

"ethtool eth0" output is the same as yesterday.

Here's the addresses and routing table as they are now, and have been 
since reboot:

$ ip -6 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
     inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
     inet6 2a00:800:752:1::5c:2/112 scope global
        valid_lft forever preferred_lft forever
     inet6 fe80::224:81ff:fea3:4424/64 scope link
        valid_lft forever preferred_lft forever


$ ip -6 r sh
2a00:800:752:1::5c:0/112 dev eth0  proto kernel  metric 256  mtu 1500
advmss 1440 hoplimit 4294967295

fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
hoplimit 4294967295

default via 2a00:800:752:1::5c:1 dev eth0  metric 1024  mtu 1500 advmss
1440 hoplimit 4294967295

$ ip -6 ne sh
2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router STALE

[try ping6 again, no reply]

$ ip -6 ne sh
2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router DELAY

[try ping6 again, no reply]

$ ip -6 ne sh
2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router REACHABLE

[try ping6 again, no reply]

Configured network with /etc/network/interfaces:

auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet static
 	address x.x.x.x
 	netmask 255.255.255.252
 	broadcast x.x.x.x
 	gateway x.x.x.x
 	up ip a a 2a00:800:752:1::5c:2/112 dev eth0
 	up ip r a default via 2a00:800:752:1::5c:1
 	dns-nameservers x.x.x.x
 	dns-search xxxx.net

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
