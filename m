From: Kevin Dwyer <kevin@pheared.net>
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Thu, 15 Aug 2002 12:10:11 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208151205240.9904-100000@kaneda.isrd.lan>
References: <200208151533.TAA26970@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Robertson <alanr@unix.sh>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208151533.TAA26970@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Thu, 15 Aug 2002, kuznet@ms2.inr.ac.ru grunted something like:

> You forgot to say what kind of "bogus result" is obtained.

Since I'm the one who has primarily been chasing this problem, I'll
explain.

(cut from my original email...)

Specifically, it uses iproute to add aliases to a device, like eth0 in
this example:

ip -f inet addr add 10.5.5.1 dev eth0 scope link
ip -f inet addr add 10.5.5.2 dev eth0 scope link
ip -f inet addr add 10.5.5.3 dev eth0 scope link
ip -f inet addr add 10.5.5.4 dev eth0 scope link
ip -f inet addr add 10.5.5.5 dev eth0 scope link

That's all fine, except that it causes really weird stuff to happen to the
output of ifconfig.  For one, the inet addr: field will change once in a
while if I make a modification with ifconfig.  That doesn't affect
heartbeat, but the Bcast: field is wrongly reported as 0.0.0.0.  Now, I
know for a fact that I set it correctly when I bring up the interface,
prior to using the ip route commands.  Once they've been applied, it goes
crazy.  So my question: Does anyone know if there's an ip route command to
make the Bcast field show up as the correct value, or is there a better
way for heartbeat to get the broadcast address?

(and from a followup email...)

# ip addr show eth0 primary scope global

2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:c0:95:e1:bc:64 brd ff:ff:ff:ff:ff:ff
    inet 10.5.5.8/24 brd 10.5.5.255 scope global eth0

That command gives me the correct broadcast address in the brd field.

Correct meaning, the one we're looking for, and would otherwise have
gotten if I hadn't used the before-mentioned iproute commands.

Any help is appreciated.

Thanks.

-[ kevin@pheared.net                 devel.pheared.net ]-
-[ Rather be forgotten, than remembered for giving in. ]-
-[ ZZ = g ^ (xb * xa) mod p      g = h^{(p-1)/q} mod p ]-
