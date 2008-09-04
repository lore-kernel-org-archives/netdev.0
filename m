From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 10:45:54 -0700
Message-ID: <20080904104554.32ffebea.akpm@linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au>
	<20080903214634.ea17ff53.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org>
	<20080903223318.84b6ce8b.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org>
	<20080904012544.cabed847.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org>
	<20080904015701.5959623a.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51223 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbYIDRqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 13:46:24 -0400
In-Reply-To: <alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Sep 2008 02:07:05 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Thu, 4 Sep 2008, Andrew Morton wrote:
> > > 
> > > commit 5f17cfce5776c566d64430f543a289e5cfa4538b
> > > 
> > >     PCI: fix pbus_size_mem() resource alignment for CardBus controllers
> > 
> > Is this worth backporting into 2.6.26.x?
> 
> It's certainly at least *potentially* -stable material, but because I 
> suspect that the whole yenta_allocate_resources() -> pci_setup_cardbus() 
> fallback code will end up resulting in a working setup, it may not be 
> worth it.  At least not until we've heard from more people..
> 
> Can you check whether your vortex cardbus thing _works_ even without the 
> fix?
> 

Working on it, but got distracted by a /proc/net bug.



sony:/home/akpm> ifconfig -a
Warning: cannot open /proc/net/dev (Permission denied). Limited output.
Warning: cannot open /proc/net/dev (Permission denied). Limited output.
eth0      Link encap:Ethernet  HWaddr 00:01:4A:9F:7C:79  
          inet addr:192.168.2.10  Bcast:192.168.2.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

Warning: cannot open /proc/net/dev (Permission denied). Limited output.
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1

sony:/home/akpm> ls -l /proc/net/dev
ls: /proc/net/dev: Permission denied

sony:/home/akpm> ls -l /proc/net
ls: /proc/net: Permission denied

sony:/home/akpm> ls -ld /proc/net
ls: /proc/net: Permission denied

sony:/home/akpm> ls -l /proc | grep net
?---------  ? ?         ?                 ?            ? /proc/net


This is a pull of your tree from yesterday, ending at


commit fbb16e243887332dd5754e48ffe5b963378f3cd2
Author: Thomas Gleixner <tglx@linutronix.de>
Date:   Wed Sep 3 00:54:47 2008 +0200

    [x86] Fix TSC calibration issues

config: http://userweb.kernel.org/~akpm/config-sony.txt
dmesg: http://userweb.kernel.org/~akpm/dmesg-sony-without.txt
