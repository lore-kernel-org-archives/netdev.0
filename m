From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
	d80211-specific qdisc
Date: Thu, 02 Nov 2006 15:58:14 -0500
Message-ID: <1162501094.4180.3.camel@localhost.localdomain>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight>
	 <20061102141815.GA1795@infradead.org>
	 <20061102164213.19bc6176@griffin.suse.cz>
	 <Pine.LNX.4.64.0611021703230.2999@mercury.sdinet.de>
	 <20061102193839.4884ae56@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:11954 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751973AbWKBU5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 15:57:44 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061102193839.4884ae56@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 19:38 +0100, Jiri Benc wrote:
> On Thu, 2 Nov 2006 17:09:24 +0100 (CET), Sven-Haegar Koch wrote:
> > At least the ones used on my machines all do.
> > (Debian Sarge, Etch and Unstable)
> > The configfiles can be changed without problems to use any device name, 
> > but needing to edit various files just for a kernel update would inhibt me 
> > from just trying a new version until I really know I would not need to go 
> > back to the old version again.
> 
> Then your config scripts don't work with Prism and Zydas cards. Something
> is broken with your setup.
> 
> > (Switching wireless from eth1 to eth2 after copying the harddisk contents 
> > to a new laptop was work enough, but at least expected with a new machine 
> > and changed hardware)
> 
> Because nobody can guarantee you even the order of your Ethernet interfaces
> with newer kernels (e.g. your eth0 Ethernet card may become eth1 at any
> time) and it will become even worse with the parallel device discovery,
> your setup is going to explode anyway.
> 
> Sorry, I can't take this as an argument. Using your argumentation, we must
> preserve wlan0 name because scripts of zd1201 users will break otherwise.
> Or - wait a moment - no no, we must preserve ath0 name because of madwifi
> users - and oh, we must preserve eth1 (not ethX because the scripts cannot
> deal with it) because of ipw users. And we must definitely ensure that card
> numbers won't ever change. Even if you uplug them and replug to another
> slots in a different order.
> 
> Sorry, that cannot work.

Right.

Nothing should be relying on the actual device name, they should be
relying on the MAC address or some other UID of the actual device.  In
many distros, the config scripts depend on a set name, but only _AFTER_
they have check the devices MAC address, matched that up with a
MAC->devname table, and renamed the device.  That's somewhat sane, but
scripts cannot just rely on the device name without checking some other
unique attribute of the device.

Dan

>  Jiri
> 

