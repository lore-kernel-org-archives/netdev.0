From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Thu, 8 Jul 2010 14:19:30 -0700
Message-ID: <20100708211930.GA15385@kroah.com>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
 <20100621150826.762ac9f2.akpm@linux-foundation.org>
 <m1mxuodo0n.fsf@fess.ebiederm.org>
 <20100621222938.GA20583@suse.de>
 <m1eig0dmhk.fsf@fess.ebiederm.org>
 <20100621231058.GA1066@suse.de>
 <m14ogwc4ou.fsf@fess.ebiederm.org>
 <20100622035631.GA3755@suse.de>
 <m1630q7x5v.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:58535 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756874Ab0GHVTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 17:19:34 -0400
Content-Disposition: inline
In-Reply-To: <m1630q7x5v.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 08, 2010 at 09:31:24AM -0700, Eric W. Biederman wrote:
> 
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

With this patch, how does the existing code fail as the drivers aren't
fixed up?

I like this change, just worried it will cause problems if it gets into
.35, without your RFC patch.  Will it?

thanks,

greg k-h
