From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Thu, 22 Jul 2010 13:30:27 +0200
Message-ID: <1279798228.12439.13.camel@jlt3.sipsolutions.net>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	 <20100621150826.762ac9f2.akpm@linux-foundation.org>
	 <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	 <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	 <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	 <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	 <1279792459.12439.0.camel@jlt3.sipsolutions.net>
	 <m139vb25nz.fsf@fess.ebiederm.org>
	 <1279793435.12439.3.camel@jlt3.sipsolutions.net>
	 <m1mxtjztvy.fsf@fess.ebiederm.org>
	 <1279795286.12439.8.camel@jlt3.sipsolutions.net>
	 <m1sk3bycxl.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:43405 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603Ab0GVLa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 07:30:56 -0400
In-Reply-To: <m1sk3bycxl.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 04:27 -0700, Eric W. Biederman wrote:

> >> Do we have a convenient command line tool to do this?
> >> I remember there being a different netlink message from
> >> normal network devices.
> >
> > iw phy0 set netns <pid>
> >
> > http://git.sipsolutions.net/iw.git
> >
> >> > root@kvm:~# ip link
> >> > 3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
> >> >     link/ether 02:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> >> > 7: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN 
> >> >     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> >> > root@kvm:~# ls /sys/class/net/
> >> > eth0  hwsim0  lo  wlan1  wlan2
> >> 
> >> I think this is actually the output of something working.
> >> 
> >> I expect after you created a new netns you didn't mount
> >> a new instance of /sys.  /sys remembers which netns you
> >> had when you mounted it.  So you have to mount /sys again
> >> so you can see the /sys/class/net for the network namespace
> >> you are in.
> >
> > Ohh, oops! I saw all the "current->" references in the code and somehow
> > expected the same instance of sysfs to show the right thing.
> >
> > Yes, it works now. But the patch below doesn't seem to work, am I
> > missing something?
> 
> You are trying to move the phy devices as well?

Yes. The intent is that each wireless phy lives in a netns along with
all of its child devices.

> My guess is that at least part of the problem is that you don't have a
> ieee80211 directory under hwsim.

But I should have? 'ieee80211' is a class just like 'net', no?

> My apologies for not thinking about the peculiarities of the wireless
> drivers.

No worries.

johannes

