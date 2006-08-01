From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Mon, 31 Jul 2006 17:46:41 -0700 (PDT)
Message-ID: <20060731.174641.99457765.davem@davemloft.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	<20060727.183415.104032934.davem@davemloft.net>
	<200608010231.58339.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55955
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751341AbWHAArZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 20:47:25 -0400
To: ak@suse.de
In-Reply-To: <200608010231.58339.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 1 Aug 2006 02:31:58 +0200

> Playing devil's advocate here: if the packets are processed on
> two different CPUs then this could also happen and break the test
> case.
> 
> So the test is probably a bit fragile.

Good point.

> I generally agree it's better to keep this in kernel though.

To drive this home even more, I do not believe that the people who
advocate pushing NDISC and ARP policy into userspace would be very
happy if something like the RAID transformations were moved into
userspace and they were not able to access their disks if the RAID
transformer process in userspace died.

Why is this a relevant analogy?  Well, you have physical hard-disks in
your computer today, but at some point that device becomes largely
superfluous.  It makes more sense to have just a cpu with a 10-gigabit
ethernet interface incorporated onto the cpu die, and the majority if
not all of your disk access is remote.

At that point, network access equals disk access.  It would be amusing
to need to restart such an NDISC/ARP daemon if it were to live on a
remote volume. :-)

I understand full well that on special purpose network devices this
control vs. data plane seperation into userspace might make a lot of
sense.  But for a general purpose operating system, such as Linux, the
greater concern is resiliency to failures and each piece of core
functionality you move to userspace is a new potential point of
failure.
