From: Jiri Kosina <jikos@kernel.org>
Subject: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 16:44:23 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've came across the behavior where adding a child qdisc and then deleting 
it again makes the networking dysfunctional (I guess that's because all of 
a sudden there is absolutely no working qdisc on the device, although 
there originally was a default one in the parent).

In a nutshell, is this expected behavior or bug?

=====
jikos:~ # tc qdisc show
qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
jikos:~ # ping -c 1 nix.cz | head -2
PING nix.cz (195.47.235.3) 56(84) bytes of data.
64 bytes from info.nix.cz (195.47.235.3): icmp_seq=1 ttl=89 time=1.59 ms

jikos:~ # tc qdisc add dev eth0 parent 10:1 sfq
jikos:~ # tc qdisc show
qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
qdisc sfq 8008: dev eth0 parent 10:1 limit 127p quantum 1514b depth 127 divisor 1024 

jikos:~ # ping -c 1 nix.cz | head -2
PING nix.cz (195.47.235.3) 56(84) bytes of data.
64 bytes from info.nix.cz (195.47.235.3): icmp_seq=1 ttl=89 time=1.67 ms

jikos:~ # tc qdisc del dev eth0 parent 10:1 sfq
jikos:~ # tc qdisc show
qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
jikos:~ # ping -c 1 nix.cz | head -2
PING nix.cz (195.47.235.3) 56(84) bytes of data.
	[ ... nothing happens ... ]
^C
jikos:~ # tc qdisc add dev eth0 parent 10:1 sfq
jikos:~ # ping -c 1 nix.cz | head -2
PING nix.cz (195.47.235.3) 56(84) bytes of data.
64 bytes from info.nix.cz (195.47.235.3): icmp_seq=1 ttl=89 time=1.66 ms
=====

Thanks,

-- 
Jiri Kosina
