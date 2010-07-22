From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Thu, 22 Jul 2010 12:10:34 +0200
Message-ID: <1279793435.12439.3.camel@jlt3.sipsolutions.net>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	 <20100621150826.762ac9f2.akpm@linux-foundation.org>
	 <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	 <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	 <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	 <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	 <1279792459.12439.0.camel@jlt3.sipsolutions.net>
	 <m139vb25nz.fsf@fess.ebiederm.org>
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
Received: from he.sipsolutions.net ([78.46.109.217]:38127 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab0GVKL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 06:11:27 -0400
In-Reply-To: <m139vb25nz.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 03:05 -0700, Eric W. Biederman wrote:

> >> Detect this problem up front and simply don't create symlinks we won't
> >> be able to remove later.  This prevents symlink leakage and fails in
> >> a much clearer and more understandable way.
> >
> > Eric, I was looking into sysfs netns support for wireless, and with this
> > patch applied I just get the warning and no network interfaces.
> 
> The warning patch just makes things fail faster.  Although I get some of the
> wireless interfaces for hwsim when I use this one.

Hmm, I didn't.

> > Was there any patch that was supposed to fix hwsim?
> 
> - If you have my patches that fix CONFIG_SYSFS_DEPRECATED,
>   you should find everything works there.

But then I was carrying those two patches too.

> As for a proper fix I have just resent my one liner to
> drives/base/core.c I can't think of a better option right now.
> 
> For hwsim it is arguable, but the behaviour of sysfs for the
> bluetooth bnep driver is very clearly a 3 year old regression,
> and the cause is exactly the same.

Right, it actually starts working again with that patch you sent.
However, netns support is really broken:

<create net namespace, put phy0/wlan0 into it>

root@kvm:~# ip link
3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 02:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
7: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
root@kvm:~# ls /sys/class/net/
eth0  hwsim0  lo  wlan1  wlan2

johannes

