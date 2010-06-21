From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Always create network class directories in get_device_parent.
Date: Mon, 21 Jun 2010 16:00:38 -0700
Message-ID: <m1r5k0c7op.fsf@fess.ebiederm.org>
References: <1276250151.3640.11.camel@jlt3.sipsolutions.net>
	<AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
	<1276507247.3926.13.camel@jlt3.sipsolutions.net>
	<bug-16215-7251@https.bugzilla.kernel.org/>
	<AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
	<m139wiuswa.fsf_-_@fess.ebiederm.org>
	<AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
	<1277033628.3642.1.camel@jlt3.sipsolutions.net>
	<AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com>
	<m1ocf5hnwh.fsf_-_@fess.ebiederm.org>
	<20100621222047.GA27848@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50754 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab0FUXAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 19:00:42 -0400
In-Reply-To: <20100621222047.GA27848@kroah.com> (Greg KH's message of "Mon\, 21 Jun 2010 15\:20\:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

>> diff --git a/drivers/base/core.c b/drivers/base/core.c
>> index 9630fbd..ffb8443 100644
>> --- a/drivers/base/core.c
>> +++ b/drivers/base/core.c
>> @@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct device *dev,
>>  		 */
>>  		if (parent == NULL)
>>  			parent_kobj = virtual_device_parent(dev);
>> -		else if (parent->class)
>> +		else if (parent->class && (strcmp(dev->class->name, "net") != 0))
>
> No, we will not have subsystem specific hacks in the driver core like
> this.  What would cause us to ever be able to delete this line?

That entire if clause is a hack.  I have just made it narrower.

If it were actually a serious possibility to convert these drivers with the
existing device core I would be happy to see something else.

Kyle and Johannes went back and forth and could not figure out how to
correctly convert the mac80211_hwsim driver to a bus device, the support
is not in the device core.

Eric
