From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Mon, 7 Jun 2010 13:05:03 +0200
Message-ID: <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
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
	<1275905686.29978.3.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47399 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab0FGLFT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 07:05:19 -0400
Received: by gwb15 with SMTP id 15so988814gwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 04:05:18 -0700 (PDT)
In-Reply-To: <1275905686.29978.3.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 12:14, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> On Mon, 2010-06-07 at 11:53 +0200, Kay Sievers wrote:
>
>> > Can you please tell me then how to device_create() without a class=
? I
>> > cannot seem to create devices without a class at all, even using m=
anual
>> > allocation (yuck) and device_register crashes the kernel.
>>
>> Right, this "convenience API" does not exist for buses. It's not doi=
ng
>> much, just allocates a "struct device" and fills in the few values a=
nd
>> calls device_register().
>>
>> Does your device create a device node? If not, device_create() shoul=
d
>> not be used anyway, because the corresponding device_destroy() will
>> not do anything.
>
> No, it doesn't need a dev node. I tried this:
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data->dev =3D kzal=
loc(sizeof(struct device), GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!data->dev) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0err =3D -ENOMEM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto failed_drvdata;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_set_name(data-=
>dev, "hwsim%d", i);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data->dev->bus =3D=
 &hwsim_bus;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0data->dev->dri=
ver =3D &mac80211_hwsim_driver;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D device_reg=
ister(data->dev);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_DEBUG
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"mac80211_hwsim: device_register fai=
led (%d)\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 goto failed_drvdata;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
> (ignore the pluses, snipped from a patch) but it ran into a null ptr
> deref?

Oh, I see. It's probably something nobody ever did before. You try to
register a bus device which has no parent. Seems that's something
nobody ever expected to happen. :)

Your driver/subsystem is completely virtual, does not depend on any
hardware, right? If we create a virtual parent, like:
  parent =3D kzalloc(sizeof(struct device), GFP_KERNEL);
  dev_set_name(parent, "mac80211_hwsim");
  device_register(parent);

An in your code:
  data->dev->parent =3D parent;

That should give you a /sys/devices/mac80211_hwsim/ directory where
all the devices you create should show up.

If that works as expected, we should probably add something like:
   struct device *device_virtual_parent(const char *name);
which will allow you to create such a parent device in the
/sys/device/virtual/ directory.

Let me know if the above hack with the virtual parent works, then we
can check what do add to the core.

Thanks,
Kay
