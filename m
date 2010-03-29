From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 17:27:29 +0200
Message-ID: <4BB0C6E1.2090606@petalogix.com>
References: <4BB09021.6020202@petalogix.com> <1269864994.2164.21.camel@edumazet-laptop> <4BB0BF28.5090505@petalogix.com>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB0BF28.5090505@petalogix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Simek wrote:
> Eric Dumazet wrote:
>> Le lundi 29 mars 2010 =C3=A0 13:33 +0200, Michal Simek a =C3=A9crit =
:
>>
>>> Do you have any idea howto improve TCP/UDP performance in general?
>>> Or tests which can point me on weak places.
>>
>> Could you post "netstat -s" on your receiver, after fresh boot and y=
our
>> iperf session, for 32 MB and 256 MB ram case ?
>>
>=20
> I am not sure if is helpful but look below.
>=20
Sorry I forget to c&p that second part. :-(

Look below.
Michal

32MB

~ # cat /proc/meminfo | head -n 1
MemTotal:          30024 kB
~ # iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port 43=
577
[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-50.0 sec  78.0 MBytes  13.1 Mbits/sec
~ # ./netstat -s
Ip:
     56596 total packets received
     0 forwarded
     0 incoming packets discarded
     56596 incoming packets delivered
     15752 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     0 active connections openings
     1 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     56596 segments received
     15752 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
error parsing /proc/net/snmp: Success



256MB


~ # cat /proc/meminfo | head -n 1
MemTotal:         257212 kB
~ # iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port 46=
069
[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-50.2 sec  19.5 MBytes  3.26 Mbits/sec
~ # ./netstat -s
Ip:
     14163 total packets received
     0 forwarded
     0 incoming packets discarded
     14163 incoming packets delivered
     5209 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     0 active connections openings
     1 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     14163 segments received
     5209 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
error parsing /proc/net/snmp: Success



--=20
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-3009066=
3
