From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: RFC: dsa slave open handling
Date: Mon, 7 Mar 2011 20:38:53 +0100
Message-ID: <20110307193853.GA16649@mail.wantstofly.org>
References: <871v2inajz.fsf@macbook.be.48ers.dk> <20110307182308.GY16649@mail.wantstofly.org> <87wrkalo4s.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:59065 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab1CGTiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 14:38:55 -0500
Content-Disposition: inline
In-Reply-To: <87wrkalo4s.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 08:35:47PM +0100, Peter Korsgaard wrote:

>  >> Currently the state of the dsa master device and slave devices are not
>  >> synchronized which leads to various issues. With dsa, the master device
>  >> needs to be running before you can use the slave devices, but it
>  >> shouldn't be used directly for I/O.
> 
>  Lennert> I think this should not be handled any differently than VLAN
>  Lennert> interfaces, where eth0 needs to be up before you can exchange
>  Lennert> packets over eth0.123.
> 
>  Lennert> IOW, if you want to do DHCP over wan (a DSA-tunneled interface
>  Lennert> over eth0), then just use an initramfs that sets eth0 up and
>  Lennert> then runs a DHCP client on wan.
> 
> True. There are a few differences between vlans and dsa devices though,
> which might make us want to handle them differently:
> 
> - VLANs are configured at runtime from userspace, DSA devices are
>   configured directly in kernel code (E.G platform devices) - So by
>   definition you cannot use the autconfig / nfsroot stuff on VLANs as
>   they are not created before userspace runs, but DSA devices are
>   basically indistinguishable from "real" devices from the POV of
>   userspace.

Sure.  That doesn't change the argument, though.  In fact, in most
situations, you'll e.g. want to bridge the lan[1-4] interfaces
together, and if you then want to DHCP over that bridge, you cannot
explain that to the kernel autoconfigurator either.


> - VLANs relation to their upstream ethernet device is clearly visible
>   (E.G through brctl), whereas the details about what interface a DSA
>   switch is connected to isn't.

commit c084080151e1de92159f8437fde34b6e5bebe35e
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Fri Mar 20 09:49:49 2009 +0000

    dsa: set ->iflink on slave interfaces to the ifindex of the parent
    
    ..so that we can parse the DSA topology from 'ip link' output:
    
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    4: lan1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
    5: lan2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    6: lan3@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    7: lan4@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


cheers,
Lennert
