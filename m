From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Tue, 08 Jun 2010 17:06:30 +0200
Message-ID: <1276009590.3706.135.camel@jlt3.sipsolutions.net>
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
	 <1276007174.3706.133.camel@jlt3.sipsolutions.net>
	 <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37558 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab0FHPGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 11:06:34 -0400
In-Reply-To: <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 16:47 +0200, Kay Sievers wrote:

> > So ... can we apply Eric's patch for now then?
> 
> It might break other stuff we don't know about yet. Just like we did
> not know about what things hwsim is doing here. :)

True.

> The hwsim issues are caused by the current hwsim code, by doing things
> it should not do. Class devices of different classes must never be
> stacked (the core should not allow that in the first place). Class
> devices must never have a driver assigned behind its back. Also
> device_create() should not be used for devices without a major/minor
> (but that seems to be done in several other places too).

Back when hwsim was written that would have been useful feedback to
whoever did ... now, not so much.

> To fix the hwsim driver core interaction, core changes will probably
> be needed to allow network modules to be removed while their devices
> are active. That's something which seems not to work for bus devices
> currently.

Well it just needs to pin the module refcount from the bus and/or device
struct. That seems not too hard?

johannes

