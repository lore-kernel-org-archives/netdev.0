From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 07 Nov 2002 15:29:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCAF76A.9080409@candelatech.com>
References: <Pine.LNX.4.44.0211061458310.13934-100000@beohost.scyld.com> <3DCA1152.7040002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> 
> Here's an update of the tulip-NAPI and skb-recycle patches.  I made some
> changes to get it to compile and work when the RECYCLE define in skbuff.h
> was not enabled.
> 
> I also got some test runs in.  Nothing really conclusive.
> 
> Test setup:  Phobos 4-port NIC in each P-IV 1.8Ghz machine 32/33 PCI bus.
> Kernel 2.4.20-rc1 + my patches.  NICs connected to each other over CX 
> cables.
> Sending 4k 1514 byte packets per second, send + receive. (48Mbps or so)
> RX ring size is 1024 for all of these tests.  No significant errors 
> reported
> by the driver.  I don't know where these dropped packets go..no counter
> seems to be catching them.

I changed to use smaller packets 757 bytes long, and to send/receive twice
as many (8kpps).  Still running at 50Mbps or so.

rx-ring is 256, still using skb-recycling with 300 skb hotlist.

Out of 57 million sent, dropped about 24k packets.  I also see about
3k of Rx-Drops on each interface.  No other significant errors reported
by the driver....

Any ideas for what to try next?  What about upping the skb-hotlist to
1024 or so?  Maybe also pre-load it with buffers to make it less likely we'll
run low?  (Rx-Drops means it could not allocate a buffer, right?)

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
