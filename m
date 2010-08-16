From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Mon, 16 Aug 2010 12:59:44 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se> <1281953960.2524.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Thomas Habets <thomas@habets.pp.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281953960.2524.23.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2010, Eric Dumazet wrote:
>> $ ip -6 r sh
>> 2a00:800:752:1::5c:0/112 dev eth0  proto kernel  metric 256  mtu 1500
>> advmss 14 hoplimit 4294967295 unreachable
>
> advmss 14 ? or is it a copy/paste error ?
> unreachable ?

Copy/paste error, sorry.

advmss 1440, and no "unreachable"

Complete (correct) line:

2a00:800:752:1::5c:0/112 dev eth0 proto kernel metric 256 mtu 1500 advmss 
1440 hoplimit 4294967295

> This route seems wrong.

Did you mean the below?

>> 2a00:800:1000:64::1 dev lo proto kernel  metric 256  error -101 mtu 
>> 16436 advmss 16376 hoplimit 4294967295

Yes, that's where the "unreachable" belonged.

unreachable 2a00:800:1000:64::1 dev lo proto kernel  metric 256  error 
-101 mtu 1500 advmss 1440 hoplimit 4294967295

That's an additional address on the lo interface, seen here again:

>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
>>      inet6 2a00:800:1000:64::1/128 scope global
>>         valid_lft forever preferred_lft forever
>>      inet6 ::1/128 scope host
>>         valid_lft forever preferred_lft forever

Am I not allowed to add addresses to lo? That I've deconfigured this 
address and rebooted the box to check if this matters.

> I am wondering if you have some lowlevel problem, say lost frames in an
> otherwise idle link, maybe a full/half duplex mismatch ?

But at first it works perfectly, and then it doesn't work at all. The link 
is ~idle both before and after, and IPv4 is unaffected. When I run "ip ne 
del ..." it *immediately* starts working again. From 100% packet loss to 
0%.

Duplex is full according to dmesg and ethtool (mii-tool says 1000BaseT-HD, 
but I suppose mii-tool is not as reliable?).

Cisco router also says "Full-duplex, 1000Mb/s", so there doesn't seem to 
be a mismatch. No errors in "show int giX/Y" either.

ethtool info right after reboot (when ipv6 is still working):
$ sudo ethtool eth0
Settings for eth0:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 1
         Transceiver: internal
         Auto-negotiation: on
         Supports Wake-on: g
         Wake-on: g
         Current message level: 0x000000ff (255)
         Link detected: yes


No errors show in "ethtool -S eth0 | grep -v ': 0$'" now that it's 
working.

I will re-check ethtool and Cisco router output for mismatches when it 
breaks again to make sure that there's no change or errors counting up.


---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
