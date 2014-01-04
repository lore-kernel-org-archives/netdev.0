From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sat, 04 Jan 2014 19:53:13 +0100
Message-ID: <20140104185313.18790@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ben Greear" <greearb@candelatech.com>, netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:62215 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbaADSxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 13:53:17 -0500
Received: from mailout-eu.gmx.com ([10.1.101.213]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MbvXU-1VjVf80cqM-00JIXm for
 <netdev@vger.kernel.org>; Sat, 04 Jan 2014 19:53:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, I compiled kernel 3.2.53 with the lates stable grsec patch, and enabled the CONFIG_PAX_REFCOUNT.

Unfortuantly the server lockedup after about 13hours so i did not get a dmesg event. forgot to disable vty blank, so don't know the reason for the server lockup.(could just be a bad kernel build).

I have rebuildt the kernel and will report back with the result, should have some results in about 16hours, unless the server locksup again.


----- Original Message -----
From: Hannes Frederic Sowa
Sent: 01/03/14 08:37 AM
To: Bob Falken
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
 On Sat, Dec 21, 2013 at 11:35:00PM +0100, Bob Falken wrote:
> On Thu, Dec 19, 2013 at 09:24:18AM -0800, Eric Dumazet wrote:
> > On Thu, 2013-12-19 at 17:28 +0100, Bob Falken wrote:
> > > The only reason why i give information about 2.6.36.4 is that its the
> > > only latest kernel that was functioning properly.
> > > i.e kernel >= 2.6.37 is not woking. so its a bisecting of the kernel
> > > versions to help a coder see when/where the isse was implemented in
> > > the kernel.
> > > 
> > > I do not need a backport patch for an old kernel, I generally only
> > > need the issue looked into and get fixed so that I dont have to use an
> > > old kernel. :)
> > > 
> > > I have no issue reproducing the issue on the recent kernels. however i
> > > have not tried the GIT kernel.
> > > 
> > > I restarted the server just a moment ago. i will install and run
> > > dropwatch and provide feedback in about 17hours. 
> > 
> > You said that "cat /proc/net/ip_mr_cache" gives nothing at all after
> > 2^32 packets ?
> > 
> > Thats a bit scary ... maybe a 32bit refcnt overflow, because of some
> > imbalance...
> 
> That's my thought, too. :/
> 
> The ipmr.c rcu conversion happend in 2.6.37. 
> 

Just as a follow-up. You could verify if we actually have a refcount overflow
if you try a grsec kernel with PAX_REFCOUNT enabled. If a refcoount overflow
happens, dmesg should show then.

Greetings,

 Hannes 
