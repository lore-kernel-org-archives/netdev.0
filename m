From: md@Linux.IT (Marco d'Itri)
Subject: Re: broken link-local multicast?
Date: Mon, 18 Feb 2008 02:21:24 +0100
Message-ID: <20080218012124.GA13035@bongo.bofh.it>
References: <alpine.LRH.1.00.0802150928020.3621@netcore.fi> <OFC0F61926.E02437A5-ON882573F0.002AA552-882573F0.002BD5F2@us.ibm.com> <20080214162834.GA29186@bongo.bofh.it> <alpine.LRH.1.00.0802150928020.3621@netcore.fi>
Reply-To: md@linux.it, netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from attila.bofh.it ([213.92.8.2]:54331 "EHLO attila.bofh.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758131AbYBRBVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 20:21:43 -0500
Content-Disposition: inline
In-Reply-To: <OFC0F61926.E02437A5-ON882573F0.002AA552-882573F0.002BD5F2@us.ibm.com> <alpine.LRH.1.00.0802150928020.3621@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 15, Pekka Savola <pekkas@netcore.fi> wrote:

>> root@frwl-5a:~# ping6 -c 1 -I eth1 ff02::1
>> connect: Network is unreachable
>
> Maybe 'netstat -gn' could give clues, because you should be receiving a 
> response at least from the loopback address.  Maybe your loopback  
> interface has went down, or ospf6d took it down and back up (at least  
> some time ago, kernel's v6 got very confused after that).
The loopback is up. ospf6d /may/ have done something to it, but I do not
know how to check this (and I cannot reboot these servers right now).

1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever

> You may also want to check out that your link-local address on the  
> interface you're pinging is still OK.
Apparently it is:

root@frwl-5a:~#  netstat -gn | grep eth1
eth1            1      224.0.0.5
eth1            1      224.0.0.1
eth1            1      ff02::6
eth1            1      ff02::5
eth1            2      ff02::1:ff00:0
eth1            1      ff02::2
eth1            1      ff02::1:ff00:89
eth1            1      ff02::1:ffd8:7dd
eth1            1      ff02::1

These (except ff02::1:ffd8:7dd, which is different) are the same
addresses of eth0, which works.

On Feb 15, David Stevens <dlstevens@us.ibm.com> wrote:

> Marco,
>         You called this a "firewall" -- do you get the same thing
> when you have no iptables rules?
Yes, I double checked again and reproduced these results with totally
empty v6 chains.

-- 
ciao,
Marco
