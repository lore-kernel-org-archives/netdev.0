From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 11:05:42 -0700
Message-ID: <m1y6exux6x.fsf@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org>
	<1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org>
	<1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org>
	<1275501157.3915.22.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42773 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932615Ab0FBSFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:05:51 -0400
In-Reply-To: <1275501157.3915.22.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Wed\, 02 Jun 2010 19\:52\:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2010-06-02 at 10:23 -0700, Eric W. Biederman wrote:
>
>> So far that hypothesis that the target of the symlink is being removed before
>> the actual actual link looks like it could cause this.
>
> Yeah though I'm not sure how that would happen? Wouldn't the symlink
> cause the target kobject to still be referenced, and thus stay around
> until the symlink goes away?

The references don't affect visibility in sysfs.  All of that is manual
at the sysfs layer, and there doesn't appear to be a good substitute.  Generally
the device layer manages to handle all of the details automatically but it
appears something is missing.

>> Are there any other left overs in sysfs, besides just /sys/class/net/wlan0?
>
> No, not based on find /sys and diffing before/after anyway.

It is going to be a little bit before I manage to dig into this deeply.

If you want to dig into this look at sysfs_delete_link.  instrument
it so that you can see if it is called for wlan{0,1,2} and see what
ns it is called for.

My current hypothesis is something is causing us to try and delete
the symlink from the wrong namespace, so we just skip that part of it.

Eric

