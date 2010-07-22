From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't remove
Date: Thu, 22 Jul 2010 03:05:04 -0700
Message-ID: <m139vb25nz.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<1279792459.12439.0.camel@jlt3.sipsolutions.net>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:43701 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab0GVKFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 06:05:08 -0400
In-Reply-To: <1279792459.12439.0.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Thu\, 22 Jul 2010 11\:54\:19 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Thu, 2010-07-08 at 09:31 -0700, Eric W. Biederman wrote:
>> Recently my tagged sysfs support revealed a flaw in the device core
>> that a few rare drivers are running into such that we don't always put
>> network devices in a class subdirectory named net/.
>> 
>> Since we are not creating the class directory the network devices wind
>> up in a non-tagged directory, but the symlinks to the network devices
>> from /sys/class/net are in a tagged directory.  All of which works
>> until we go to remove or rename the symlink.  When we remove or rename
>> a symlink we look in the namespace of the target of the symlink.
>> Since the target of the symlink is in a non-tagged sysfs directory we
>> don't have a namespace to look in, and we fail to remove the symlink.
>> 
>> Detect this problem up front and simply don't create symlinks we won't
>> be able to remove later.  This prevents symlink leakage and fails in
>> a much clearer and more understandable way.
>
> Eric, I was looking into sysfs netns support for wireless, and with this
> patch applied I just get the warning and no network interfaces.

The warning patch just makes things fail faster.  Although I get some of the
wireless interfaces for hwsim when I use this one.

> Was there any patch that was supposed to fix hwsim?

- If you have my patches that fix CONFIG_SYSFS_DEPRECATED,
  you should find everything works there.

As for a proper fix I have just resent my one liner to
drives/base/core.c I can't think of a better option right now.

For hwsim it is arguable, but the behaviour of sysfs for the
bluetooth bnep driver is very clearly a 3 year old regression,
and the cause is exactly the same.

Eric
