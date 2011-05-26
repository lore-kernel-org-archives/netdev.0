From: Victor =?iso-8859-1?q?Matar=E9?= <matare@lih.rwth-aachen.de>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Thu, 26 May 2011 04:00:22 +0200
Message-ID: <201105260400.22814.matare@lih.rwth-aachen.de>
References: <bug-35862-10286@https.bugzilla.kernel.org/>
 <20110525163137.6f04f26e.akpm@linux-foundation.org>
 <20110525.215222.22117057747103565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:41542 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754137Ab1EZCa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 22:30:26 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LLS000545KP1X80@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 26 May 2011 04:00:25 +0200 (CEST)
Received: from wald.localnet ([unknown] [134.61.98.38])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LLS00FFR5KOXF60@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 26 May 2011 04:00:24 +0200 (CEST)
In-reply-to: <20110525.215222.22117057747103565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 26.05.2011 03:52:22 David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 25 May 2011 16:31:37 -0700
> 
> >> I switched a host's ip address from 137.226.164.13 to 137.226.164.2. The .13 IP
> >> now belongs to the host that had .2 before (I swapped them). Now both hosts
> >> still arp from their old IPs although ifconfig as well as ip clearly tell
> >> otherwise. Examining the host which now has 137.226.164.13:
> >> 
> >> # ip addr show dev eth0
> >> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
> >>     link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
> >>     inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
> >>     inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0
> 
> If you keep the old IP address around it remains as the "primary"
> IP address.
> 
> You have to explicitly remove the original IP address from the
> interface first, then add the new one, in order for the new
> one to become the "primary"
> 
> Not a bug, please close this.
> 

Sorry, there's a typo. It's supposed to read:

[...]
Examining the host which now has 137.226.164.2 (used to have 137.226.164.13):

# ip addr show dev eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
     inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
     inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0
[...]

Sorry, got confused with all the swapping. I'm *not* keeping the old address around, it's completely *gone*, from both ifconfig and ip. But still it's being used as arp src address. That's what this bug is about. Sorry for the confusion.
