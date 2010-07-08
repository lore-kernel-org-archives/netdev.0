From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't remove
Date: Thu, 08 Jul 2010 15:28:53 -0700
Message-ID: <m1r5jdbobe.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40289 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab0GHW3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 18:29:07 -0400
In-Reply-To: <20100708211930.GA15385@kroah.com> (Greg KH's message of "Thu\, 8 Jul 2010 14\:19\:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

> With this patch, how does the existing code fail as the drivers aren't
> fixed up?
>
> I like this change, just worried it will cause problems if it gets into
> .35, without your RFC patch.  Will it?

It don't expect this patch to be worse than where we are current at.
Network devices are renamed, and come and go enough that both the
mac80211_hwsim and the bnep driver are currently unusable with a
failure only the rename and remove.

This patch simply moves the failure into creation where we are a little more
prepared to deal with problems, and this patch is limited to mac80211_hwsim,
bnep, and any hypothetically undiscovered other network devices that
have the same problem.

mac80211_hwsim with just this patch becomes somewhat usable as it's primary
network device gets registered and the module can be loaded and unloaded.  It
just doesn't create the wlan0 and wlan1 interfaces for the wifi interfaces.


On a slightly unrelated note, what got us on trying to convert
mac80211_hwsim was that everything happens in a single module which
makes avoiding cleanup races hard.  I am hoping bnep is structured
enough differently so we can convert it to a bus device using the
existing infrastructure.  I haven't figured out bnep yet though ;(

Eric
