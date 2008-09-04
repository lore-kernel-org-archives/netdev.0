From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: Tree for September 3
Date: Thu, 4 Sep 2008 11:05:21 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809041058140.3400@nehalem.linux-foundation.org>
References: <20080903191619.6b6b230e.sfr@canb.auug.org.au> <20080903214634.ea17ff53.akpm@linux-foundation.org> <alpine.LFD.1.10.0809032201510.3378@nehalem.linux-foundation.org> <20080903223318.84b6ce8b.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040045190.3378@nehalem.linux-foundation.org> <20080904012544.cabed847.akpm@linux-foundation.org> <alpine.LFD.1.10.0809040143350.3452@nehalem.linux-foundation.org> <20080904015701.5959623a.akpm@linux-foundation.org>
 <alpine.LFD.1.10.0809040203510.3452@nehalem.linux-foundation.org> <20080904104554.32ffebea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@zeniv.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49082 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752958AbYIDSFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 14:05:30 -0400
In-Reply-To: <20080904104554.32ffebea.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 4 Sep 2008, Andrew Morton wrote:
> 
> Working on it, but got distracted by a /proc/net bug.

Ok, that's just something odd.

> sony:/home/akpm> ls -l /proc/net/dev
> ls: /proc/net/dev: Permission denied
> 
> sony:/home/akpm> ls -l /proc/net
> ls: /proc/net: Permission denied
> 
> sony:/home/akpm> ls -ld /proc/net
> ls: /proc/net: Permission denied
> 
> sony:/home/akpm> ls -l /proc | grep net
> ?---------  ? ?         ?                 ?            ? /proc/net
> 
> This is a pull of your tree from yesterday, ending at commit 
> fbb16e243887332dd5754e48ffe5b963378f3cd2

There's been various suggested patches by Al/Eric (added to cc) for 
/proc/net handling, but none of them have actually even been merged yet. 
So I don't think this code has changed in a while. 

Al, Eric, ideas?

> config: http://userweb.kernel.org/~akpm/config-sony.txt
> dmesg: http://userweb.kernel.org/~akpm/dmesg-sony-without.txt

That whole thing should just be a simple symlink:

	fs/proc/proc_net.c:     proc_symlink("net", NULL, "self/net");

are you sure it's a plain tree of mine, without any of the patches 
floating around between Eric/Al?

			Linus
