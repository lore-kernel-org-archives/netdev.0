From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Thu, 22 Jul 2010 11:54:19 +0200
Message-ID: <1279792459.12439.0.camel@jlt3.sipsolutions.net>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	 <20100621150826.762ac9f2.akpm@linux-foundation.org>
	 <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	 <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	 <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	 <m1630q7x5v.fsf_-_@fess.ebiederm.org>
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
Received: from he.sipsolutions.net ([78.46.109.217]:51019 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab0GVJzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 05:55:04 -0400
In-Reply-To: <m1630q7x5v.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 09:31 -0700, Eric W. Biederman wrote:
> Recently my tagged sysfs support revealed a flaw in the device core
> that a few rare drivers are running into such that we don't always put
> network devices in a class subdirectory named net/.
> 
> Since we are not creating the class directory the network devices wind
> up in a non-tagged directory, but the symlinks to the network devices
> from /sys/class/net are in a tagged directory.  All of which works
> until we go to remove or rename the symlink.  When we remove or rename
> a symlink we look in the namespace of the target of the symlink.
> Since the target of the symlink is in a non-tagged sysfs directory we
> don't have a namespace to look in, and we fail to remove the symlink.
> 
> Detect this problem up front and simply don't create symlinks we won't
> be able to remove later.  This prevents symlink leakage and fails in
> a much clearer and more understandable way.

Eric, I was looking into sysfs netns support for wireless, and with this
patch applied I just get the warning and no network interfaces.

Was there any patch that was supposed to fix hwsim?

johannes

