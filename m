From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and bnep drivers
Date: Mon, 21 Jun 2010 17:05:21 -0700
Message-ID: <m14ogwc4ou.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60063 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932523Ab0FVAFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 20:05:32 -0400
In-Reply-To: <20100621231058.GA1066@suse.de> (Greg KH's message of "Mon\, 21 Jun 2010 16\:10\:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> On Mon, Jun 21, 2010 at 03:55:35PM -0700, Eric W. Biederman wrote:
>> Greg KH <gregkh@suse.de> writes:
>> 
>> > I _really_ do not like this patch.
>> >
>> > The correct thing is to fix the modules that are affected, and that's
>> > only the wireless testing module, right?  Or is there something else?
>> >
>> > And if that code is properly converted to a bus, what needs to change in
>> > the driver core?
>> 
>> The usb bnep driver.
>
> Odd, what is bnep doing differently here from all other network drivers?
> Is it trying to stack the bluetooth class in the middle somehow?
> Shouldn't this be easy to fix up in the driver itself?

The cause of all of the failures is a class device with a class device
parent, instead of a bus device parent.  Which causes the net/ directory 
not to be created for us to put the network devices under.

I don't have a clue about how that driver works, and I don't know how many
other drivers that do something strange like this are out there lurking.

I have not been involved previously in any changes from class device to
bus device so I don't have a clue how difficult it would.  All I know
is that with the mac80211_hwsim driver we had first had two people who
really knew what they were doing and it was hard enough there still
isn't a working conversion away from class devices.

Eric
