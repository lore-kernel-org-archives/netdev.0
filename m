From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: tg3: low performance on 4-port bcm5704c NIC with IRQ sharing
Date: Fri, 17 Oct 2003 18:05:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017160549.GA2827@wsx.ksp.sk>
References: <20031017145704.GA2515@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031017145704.GA2515@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another interesting thing is that eth1 and eth2 does not work if eth0 is
down.


On Fri, Oct 17, 2003 at 04:57:05PM +0200, Jan Oravec wrote:
> Hello,
> 
> 
> I have 4-port BCM5704C NIC and this problem:
> 
> Interfaces eth0 to eth3, where IRQs of eth0 to eth2 are 28 and IRQ of eth3
> is 30. When using tg3 driver (v2.2 August 24, 2003), interfaces eth1 and
> eth2 are slow. The box is opteron, relevant parts of dmesg:
> 
> eth0: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC0>
> eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC1>
> eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC2>
> eth3: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC3>
> tg3: eth1: Link is up at 1000 Mbps, full duplex.
> tg3: eth1: Flow control is on for TX and on for RX.
> 
> What is strange is this:
> 
> 64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=10.0 ms
> 64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=9.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=8.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=7.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=6.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=5.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=4.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=3.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=2.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=1.00 ms
> 64 bytes from 10.0.0.1: icmp_seq=11 ttl=64 time=99.9 ms
> 64 bytes from 10.0.0.1: icmp_seq=12 ttl=64 time=98.9 ms
> 64 bytes from 10.0.0.1: icmp_seq=13 ttl=64 time=97.9 ms
> 64 bytes from 10.0.0.1: icmp_seq=14 ttl=64 time=96.9 ms
> ...
> 
> Even stranger is that when I run two pings, the times are not about equal,
> but each one starts at random number lower than 100 ms and is decreasing by
> 1ms.
> 
> Interfaces eth0 and eth3 are OK. The other end of cable is also 5704C.
> 
> 
> I've tried also the Broadcom bcm5700-7.0.0 driver; with this one eth1 and
> eth2 do not work at all (when cable is plugged, interface isn't RUNNING).
> 
> My opinion is that it can be something with IRQ sharing on the same NIC. I
> tried to put more 2-port NICs and it works well if interrupts are shared
> between the NICs.
> 
> The motherboard is Tyan S2880; kernel is 2.6.0-test7-bk8.
> 
> 
> Best Regards,
> 
> -- 
> Jan Oravec
> 6COM s.r.o.
> http://www.6com.sk
> 
