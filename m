From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Fri, 4 Jun 2010 10:34:07 +0200
Message-ID: <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com> <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org> <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org> <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org> <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org> <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	<1275634452.5189.1.camel@jlt3.sipsolutions.net> <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	<1275640113.9953.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45923 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab0FDIeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 04:34:23 -0400
Received: by gye5 with SMTP id 5so693204gye.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 01:34:22 -0700 (PDT)
In-Reply-To: <1275640113.9953.8.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 4, 2010 at 10:28, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Fri, 2010-06-04 at 10:15 +0200, Kay Sievers wrote:
>> On Fri, Jun 4, 2010 at 08:54, Johannes Berg <johannes@sipsolutions.net> wrote:
>> > On Wed, 2010-06-02 at 17:53 -0700, Eric W. Biederman wrote:
>> >
>> >> Johannes this should fix your issue with mac80211_hwsim, where
>> >> the device symlink were not destroyed when the driver was removed.
>> >
>> > It does, thank you.
>> >
>> > FWIW, I'm happy changing hwsim too, but I don't think I quite understand
>> > what you're proposing in your other email so I'll leave it up to you
>> > since you now know what is causing the problem :)
>>
>> Assuming that hwsim is th parent of the network interface, it should
>> us a "struct bus_type" not a "struct class" for the subsystem it
>> assigns the devices to.
>
> It's all virtual, so yeah, I guess it is the parent? It currently
> creates a virtual struct device in the hwsim class and assigns that to
> the netdev parent indirectly via the wiphy or something like that.
>
>> Classes should not be used for anything completely simple, at best not
>> be used at all, they are just too simple. We never know about future
>> requirements, which usually all go wrong with the non-extendable class
>> logic.
>>
>> The difference in the code to switch from class to bus should be minimal.
>
> Does that mean cfg80211 (net/wireless/) should also not use a struct
> class? I'm not familiar with any of these details, mind helping me out?

Everything that might ever have a child device, or might ever need a
sysfs attribute gobal to the subsystem must convert to a bus.

Actually there is not much reason to ever use "struct class" today.
The layout for classes in /sys is not extendable like it is for buses
which put all devices in a devices/ subdir and have the main subsystem
directory to add custom things.

Kay
