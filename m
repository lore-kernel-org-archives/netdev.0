From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 20:37:05 +0100
Message-ID: <20160123193705.GE3880@lunn.ch>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41354 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbcAWThK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 14:37:10 -0500
Content-Disposition: inline
In-Reply-To: <20160123190622.GA10826@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 07:06:22PM +0000, Russell King - ARM Linux wrote:
> On Sat, Jan 23, 2016 at 07:15:26PM +0100, Andrew Lunn wrote:
> > Thanks for digging into this.
> 
> I hope you saw v2, which is functionally identical.

No, not yet. I will go look for it.
 
> > I think this is a step towards a solution, but does not solve all the
> > problems.
> > 
> > e.g. I have a switch interface lan0 with the IP address
> > 192.168.10.2. I can ping this address from another host. I then take
> > the IP address off the interface, create a br0 device, add lan0 to the
> > bridge, and put 192.168.10.2 onto the bridge. I should be able to then
> > ping the address. But it does not work.
> 
> That works for me.  Maybe it's differences in the switch device?  I
> seem to remember you said your switch was an older generation than
> mine (88E6176).

I'm testing on a 6172. But 6172 and 6176 are both in the same family
6352, and share the same driver.

> root@clearfog:~# brctl show br0
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.005043020202       no              lan1
>                                                         lan2
>                                                         lan3
>                                                         lan4
>                                                         lan5
>                                                         lan6

So you initially have lan1 in an bridge. I don't.

root@370-rd:~# ip link set lan0 up                                                             
root@370-rd:~# ip addr add 192.168.10.2/24 dev lan0                                            
root@370-rd:~# ping 192.168.10.1                                                
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.                          
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=1.69 ms                      
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.953 ms                     
64 bytes from 192.168.10.1: icmp_seq=3 ttl=64 time=0.926 ms    

root@370-rd:~# ip addr del 192.168.10.2/24 dev lan0
root@370-rd:~# brctl addbr br0
root@370-rd:~# brctl addif br0 lan0
root@370-rd:~# ip link set br0 up
root@370-rd:~# ip addr add 192.168.10.2/24 dev br0                              
root@370-rd:~# ping 192.168.10.1                                                
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.                          
^C                                                                              
--- 192.168.10.1 ping statistics ---                                            
3 packets transmitted, 0 received, 100% packet loss, time 2001ms    

  Andrew
