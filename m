From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Mon, 7 Jun 2010 14:54:01 +0200
Message-ID: <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com> <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org> <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org> <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org> <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org> <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	<1275634452.5189.1.camel@jlt3.sipsolutions.net> <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	<1275640113.9953.8.camel@jlt3.sipsolutions.net> <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	<1275829701.3615.54.camel@jlt3.sipsolutions.net> <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	<1275903773.29978.1.camel@jlt3.sipsolutions.net> <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	<1275905686.29978.3.camel@jlt3.sipsolutions.net> <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	<1275910905.29978.7.camel@jlt3.sipsolutions.net> <1275913563.1823.1.camel@yio.site>
	<1275914205.29978.10.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:40949 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab0FGMyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 08:54:17 -0400
Received: by gwb15 with SMTP id 15so1047201gwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 05:54:16 -0700 (PDT)
In-Reply-To: <1275914205.29978.10.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 14:36, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2010-06-07 at 14:26 +0200, Kay Sievers wrote:
>> On Mon, Jun 7, 2010 at 13:41, Johannes Berg <johannes@sipsolutions.net> wrote:
>> > (mind you, I think we probably need to have the bus/driver assignment,
>> > but I wanted to try out your suggestion first)
>>
>> Class device can never have a driver. And unregistered drivers can
>> not be used, what you try to do here. That all should just be removed or
>> properly registered with the core if needed.
>
> Yeah but it shouldn't influence the operation?

It does. You can not use "dead static" drivers. They need to be
properly registered, and can only work for bus devices. Class devices
are not allowed to have drivers.

This worked only because the core ignored the value you assigned
behind its back. :)

>> Here is something that seems to work for me.
>
> I see you remove the driver. Does this mean that in sysfs these devices
> wouldn't have a driver symlink? ISTR that we needed that for userspace,
> but I'm not entirely sure, and I don't have all the relevant userspace
> in my test setup.

Yeah, if you need the driver, you need to use bus device, as you do
now. The driver needs to be registered with the core, and the probe
function needs to tell to bind to the devices while registered. You
can not manually assign this.

Kay
