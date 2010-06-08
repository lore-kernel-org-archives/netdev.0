From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Tue, 08 Jun 2010 16:26:14 +0200
Message-ID: <1276007174.3706.133.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	 <1275905686.29978.3.camel@jlt3.sipsolutions.net>
	 <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	 <1275910905.29978.7.camel@jlt3.sipsolutions.net>
	 <1275913563.1823.1.camel@yio.site>
	 <1275914205.29978.10.camel@jlt3.sipsolutions.net>
	 <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	 <1275989260.3706.115.camel@jlt3.sipsolutions.net>
	 <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	 <1275990325.3706.116.camel@jlt3.sipsolutions.net>
	 <1275998127.1899.38.camel@yio.site>
	 <1275998603.3706.118.camel@jlt3.sipsolutions.net>
	 <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	 <1276005970.3706.132.camel@jlt3.sipsolutions.net>
	 <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:38910 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab0FHO0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 10:26:22 -0400
In-Reply-To: <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 16:21 +0200, Kay Sievers wrote:

> > Well they will be unregistered and everything, but once all the netdevs
> > are gone etc. the devices you create in the patch might stick around
> > because somebody has them open in sysfs, and I see nothing that would
> > pin the module in that case?
> 
> That's what I mean, I have no idea how to solve that with network
> devices. I don't think any other subsytem allows to unload the module,
> when devices, the module has created, are in use.

You're right ... the would only be unregistered from your release, which
would happen after the module is long gone ...

> The current code uses the in-core class_create() logic, which was only
> meant for devices with a device node, and which is cleaned up by the
> core itself. That's why this issue never appeared before.
> 
> But as said, I have no idea how to solve that with a single module. It
> might not work at all without moving stuff into the core. That people
> use device_create() with no major/minor might indicate that something
> else is needed here. :)

So ... can we apply Eric's patch for now then?

johannes

