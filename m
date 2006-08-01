From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Mon, 31 Jul 2006 21:24:27 -0400
Message-ID: <1154395467.5170.31.camel@jzny2>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	 <20060727.183415.104032934.davem@davemloft.net>
	 <200608010231.58339.ak@suse.de>
	 <20060731.174641.99457765.davem@davemloft.net>  <ada7j1t700x.fsf@cisco.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:48062 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751450AbWHABYf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 21:24:35 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G7izx-0003SK-5X
	for netdev@vger.kernel.org; Mon, 31 Jul 2006 21:24:41 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <ada7j1t700x.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-31-07 at 17:49 -0700, Roland Dreier wrote:
>     David> Why is this a relevant analogy?  Well, you have physical
>     David> hard-disks in your computer today, but at some point that
>     David> device becomes largely superfluous.  It makes more sense to
>     David> have just a cpu with a 10-gigabit ethernet interface
>     David> incorporated onto the cpu die, and the majority if not all
>     David> of your disk access is remote.
> 
> Isn't most of the iSCSI control plane in userspace right now?

I know iscsi is supposed to integrate with ipsec as well (and SLP for
discovery) - does that happen in user space as well?

Dave (I am under heavy flu dose, so I may be incoherent;->) but heres a
devils advocate bit for you:
TCP FIN/SYN are just control packets - so move the connection
setup/teardown out to user space;->. You can then add all sorts of funky
DOS detection/prevention schemes as needed - makes it easy to experiment with. 
Actually move the slow path as well, SACK processing etc (i know it is in process
context today, but thats in the kernel). Just leave VJs fast path in the
kernel. Extend the user space bit to be the new VJ (channels stuff but
just for control) - asynch notification to carry the control/slow path
packets to user space.

In regards to ARP/NDISC being in user space: note people are talking
about secure DHCP or some form of initial pre-layer2 addressing over EAP
or something along those lines; i.e if you are not securely validated at
the L2 level you are not even getting an IP address. 
 
In regards to reliability: The thing that really fscks people using
daemons from what i have seen is the oom killer policies and the lack of
correlation by apps. I just watched quagga die horribly on a 256M
machine on friday once we hit around 100K routes and a lot of route
cache hits. So apps like that may need a total rewrite. I am not looking
forward to trying to get racoon to do 50K SAs and 100K SPDs on the same
machine ;->

I think I like what Hugo is saying ;-> I just hope he has time and
resources to produce code. 

cheers,
jamal



