From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netdev: handle setting transmit queue length on active
 device.
Date: Wed, 18 Mar 2009 19:31:39 +0100
Message-ID: <49C13E0B.30603@trash.net>
References: <20090318100237.06e974c9@nehalam>	<49C12C3A.9080107@trash.net>	<20090318110236.7fd09d09@nehalam>	<49C13887.2070801@trash.net> <20090318111605.06ed6548@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47669 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755984AbZCRSbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 14:31:45 -0400
In-Reply-To: <20090318111605.06ed6548@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 18 Mar 2009 19:08:07 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> I'd suggest to simply attach a pfifo qdisc with an explicitly
>> configured limit to activate queueing on virtual devices.
> 
> The existing code is broken if user does:
> 
> # ip li set dev eth0.200 txq 200
> # tc qdisc set dev eth0.200 root sfq
> # tc qdisc del dev eth0.200 root
> # ip li set dev eth0.200 txq 0
> 
> The vlan is now dead because it is impossible to go back
> to the no queueing (noop) qdisc.  Also, when doing performance tests
> it is useful to be able to turn off transmit queue entirely.

What I meant is:

# ip l l dummy0
109: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state 
UNKNOWN
     link/ether 0a:94:90:3c:e3:45 brd ff:ff:ff:ff:ff:ff

# tc qdisc add dev dummy0 root pfifo limit 1000
# ip l l dummy0
109: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo state 
UNKNOWN
     link/ether 0a:94:90:3c:e3:45 brd ff:ff:ff:ff:ff:ff

# tc qdisc del dev dummy0 root
# ip l l dummy0
109: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state 
UNKNOWN
     link/ether 0a:94:90:3c:e3:45 brd ff:ff:ff:ff:ff:ff

It should work your way as well if you set the transmit queue length
to zero before removing the root qdisc.
