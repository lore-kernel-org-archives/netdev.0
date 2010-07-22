From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't remove
Date: Thu, 22 Jul 2010 03:35:29 -0700
Message-ID: <m1mxtjztvy.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<1279792459.12439.0.camel@jlt3.sipsolutions.net>
	<m139vb25nz.fsf@fess.ebiederm.org>
	<1279793435.12439.3.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60329 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754944Ab0GVKfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 06:35:37 -0400
In-Reply-To: <1279793435.12439.3.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Thu\, 22 Jul 2010 12\:10\:34 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Thu, 2010-07-22 at 03:05 -0700, Eric W. Biederman wrote:
>
>> >> Detect this problem up front and simply don't create symlinks we won't
>> >> be able to remove later.  This prevents symlink leakage and fails in
>> >> a much clearer and more understandable way.
>> >
>> > Eric, I was looking into sysfs netns support for wireless, and with this
>> > patch applied I just get the warning and no network interfaces.
>> 
>> The warning patch just makes things fail faster.  Although I get some of the
>> wireless interfaces for hwsim when I use this one.
>
> Hmm, I didn't.

To be clear I just get hwsim0.  Not wlan0 or wlan1.

>> > Was there any patch that was supposed to fix hwsim?
>> 
>> - If you have my patches that fix CONFIG_SYSFS_DEPRECATED,
>>   you should find everything works there.
>
> But then I was carrying those two patches too.
>
>> As for a proper fix I have just resent my one liner to
>> drives/base/core.c I can't think of a better option right now.
>> 
>> For hwsim it is arguable, but the behaviour of sysfs for the
>> bluetooth bnep driver is very clearly a 3 year old regression,
>> and the cause is exactly the same.
>
> Right, it actually starts working again with that patch you sent.
> However, netns support is really broken:
>
> <create net namespace, put phy0/wlan0 into it>

Do we have a convenient command line tool to do this?
I remember there being a different netlink message from
normal network devices.

> root@kvm:~# ip link
> 3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>     link/ether 02:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> 7: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> root@kvm:~# ls /sys/class/net/
> eth0  hwsim0  lo  wlan1  wlan2

I think this is actually the output of something working.

I expect after you created a new netns you didn't mount
a new instance of /sys.  /sys remembers which netns you
had when you mounted it.  So you have to mount /sys again
so you can see the /sys/class/net for the network namespace
you are in.

Eric

