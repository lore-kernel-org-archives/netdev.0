From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Always create class directories fixing the
	broken network drivers.
Date: Sun, 20 Jun 2010 15:37:32 +0200
Message-ID: <AANLkTimQQpBzBodQhZk3NANLHnZjbbxJsuwO9RjBhEcF@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<1275998127.1899.38.camel@yio.site> <1275998603.3706.118.camel@jlt3.sipsolutions.net>
	<AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	<1276005970.3706.132.camel@jlt3.sipsolutions.net> <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
	<1276007174.3706.133.camel@jlt3.sipsolutions.net> <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
	<1276009590.3706.135.camel@jlt3.sipsolutions.net> <AANLkTimSqF4D4jPj-HzOjl1vxjf2T7YvlGdR6zcJZ9Pp@mail.gmail.com>
	<1276014816.3706.137.camel@jlt3.sipsolutions.net> <AANLkTilUd2Bp1h4SzlW5f5KevoRM-os_fQrivLHbZyKY@mail.gmail.com>
	<1276250151.3640.11.camel@jlt3.sipsolutions.net> <AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
	<1276507247.3926.13.camel@jlt3.sipsolutions.net> <bug-16215-7251@https.bugzilla.kernel.org/>
	<AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
	<m139wiuswa.fsf_-_@fess.ebiederm.org> <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
	<1277033628.3642.1.camel@jlt3.sipsolutions.net> <AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com>
	<m1hbkx6g6p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39655 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab0FTNhr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 09:37:47 -0400
Received: by iwn36 with SMTP id 36so8349iwn.19
        for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 06:37:47 -0700 (PDT)
In-Reply-To: <m1hbkx6g6p.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 14:29, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Kay Sievers <kay.sievers@vrfy.org> writes:
>> On Sun, Jun 20, 2010 at 13:33, Johannes Berg <johannes@sipsolutions.=
net> wrote:
>>> On Sun, 2010-06-20 at 12:52 +0200, Kay Sievers wrote:
>>>
>>>> As mentioned earlier, It's pretty fragile to change things in this
>>>> area, and I prefer the broken network driver-core interactions to =
be
>>>> fixed instead - even when they are more complicated.
>>>
>>> Can you _please_ offer a proper way to fix it then?
>>
>> Sorry, I have no real experience with the issues created by the
>> assumption that network driver need to be able to get unloaded while
>> in use. That's very special, always requires a
>> compiled-into-the-kernel part of the subsystem, and makes it hard to
>> work with, as we can not use any of the usual core infrastructure to
>> solve that.
>
> So please look at https://bugzilla.kernel.org/show_bug.cgi?id=3D16215
>
> That simply creates and destroys the network device as things come
> and go.

I'm still not sure, any help here would be appreciated.

> I think the bnep case is much more serious because it is real hardwar=
e
> not a testing simulation, and it is the second instance of this.
>
> Calling the change broken when I can boot up and run X in that
> configuration just fine is a vast overstatement.

Oh, I seriously would love this rule - it would make my work so much
easier. But I need to make it totally clear: "Adding intermediate
directories into 'input' sysfs it absolutely broken, regardless if
your box comes up or not. :)

X is using udev, and udev aggressively hides these details and forbids
matching such details, but many other tools which read sysfs directly,
including ones using the conceptually broken 'device' symlink will for
sure break with such changes.

> Especially
> when you don't acknowledge that the device layer is broken.

Stacking devices from different classes is broken, and not a direct
problem of the core. It is just not supported. The core might just
need to refuse that in the first place, but that's a different issue.

> I will agree that insane amounts of backwards compatibility are a goo=
d
> idea. =C2=A0So I will cook up a version of my patch that adds a hack =
to the
> device layer to only apply this change to devices of class net.
>
> That should save let us postpone the architectural dreams for another
> day.

It's not a dream, it needs to be fixed where it is used. We can not
allow to stack classes.

Kay
