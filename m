From: Massimo Cetra <ctrix+debianbugs@navynet.it>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Thu, 19 Apr 2012 10:37:46 +0200
Message-ID: <4F8FCEDA.20504@navynet.it>
References: <4F8E9291.9000607@navynet.it> <4F8FCB53.7070603@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host188-6-static.238-77-b.business.telecomitalia.it ([77.238.6.188]:51527
	"EHLO max.ctrix.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab2DSIiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:38:24 -0400
In-Reply-To: <4F8FCB53.7070603@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/2012 10:22, Peter Huang(Peng) wrote:
> Hi, Massimo
>
> can this be reproduce easily or depend on some HW or SW environment?
>
> This patch already verified on 2.6.32.36/54,3.3.1, 3.4.rc[23] for over
> 6 hours, but didn't encounter this problem.

The server is a Dell PowerEdge R410.

The network cards are:
01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5716 
Gigabit Ethernet (rev 20)
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5716 
Gigabit Ethernet (rev 20)

The server is doing nothing except for routing packets and running 
virtual servers.

This server is guesting about 10 KVM virtual servers in a bridged 
configuration.


lamu:~# brctl show br0
bridge name     bridge id               STP enabled     interfaces
br0             8000.0024e869f8eb       yes             eth1
                                                         kvmnet-db0
                                                         kvmnet-devel0
                                                         kvmnet-kermit0
                                                         kvmnet-mail0
                                                         kvmnet-max0
                                                         kvmnet-repo0
                                                         kvmnet-voip0
                                                         kvmnet-wper0
                                                         kvmnet-wsos0


kvmnet-* interfaces are tun devices.

-------------------------

Whenever i add a couple of "virtual" bridges assigning an ip address to, 
for example, br0:1 br0:2, the panic happens a couple of times a day.

If i leave only br0 and br1 it's very hard to trigger (but this may be 
related to network traffic which, in this case, is very low).

By the way, i'm using this kernel (with and without the previous patch) 
on my workstation which has a br0 interface and some VM attached in the 
same way.
I am not experiencing crashes and the only difference is that i don't 
have, on my desktop, any br0:1 br0:2 interfaces.

Hope it helps.

Max
