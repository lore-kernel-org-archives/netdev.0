From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 10:23:48 -0700
Message-ID: <m1ocftwdp7.fsf@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org>
	<1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org>
	<1275498007.3915.20.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43159 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758035Ab0FBRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:23:54 -0400
In-Reply-To: <1275498007.3915.20.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Wed\, 02 Jun 2010 19\:00\:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2010-06-02 at 09:43 -0700, Eric W. Biederman wrote:
>
>> > Hmm. I'm also not seeing it with veth, it would seem that ought to be
>> > similar?
>> 
>> Since it is the register_netdev path it should be exactly the same.
>> 
>> The big change I made is I in some instances I replaced
>> sysfs_remove_link with sysfs_delete_link so I could have enough
>> information to infer which network namespace the link was in.  Since
>> wlan0 is a netdevice all of that information should already be there.
>
> I have no idea :)
>
>> > I don't know if that's happening .. just guessing that it might cause
>> > such a problem, and maybe some things are deferred somehow? Since netdev
>> > destruction can be deferred, but the wifi sysfs destruction isn't. But
>> > then that link there should cause the refcount to not go down until the
>> > link goes away>?
>> 
>> unregister_netdevice will defer the final destruction but it does not
>> defer netdev_unregister_kobject -> device_del.
>> 
>> What happens if in exit_mac80211_hwsim you call unregister_netdev before
>> mac80211_hwsim_free?
>> 
>> At a quick glance it simply looks like you have the ordering reversed in your
>> module cleanup, and this is not network namespace related at all.
>
> Nah, the unregister_netdev there removes the "hwsim0" device, while the
> mac80211_hwsim_free() will remove all the others, so the ordering of
> those two doesn't matter.

So far that hypothesis that the target of the symlink is being removed before
the actual actual link looks like it could cause this.

Are there any other left overs in sysfs, besides just /sys/class/net/wlan0?

Eric
