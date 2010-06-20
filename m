From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Always create class directories fixing the
	broken network drivers.
Date: Sun, 20 Jun 2010 12:52:57 +0200
Message-ID: <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<1275914205.29978.10.camel@jlt3.sipsolutions.net> <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	<1275989260.3706.115.camel@jlt3.sipsolutions.net> <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	<1275990325.3706.116.camel@jlt3.sipsolutions.net> <1275998127.1899.38.camel@yio.site>
	<1275998603.3706.118.camel@jlt3.sipsolutions.net> <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	<1276005970.3706.132.camel@jlt3.sipsolutions.net> <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
	<1276007174.3706.133.camel@jlt3.sipsolutions.net> <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
	<1276009590.3706.135.camel@jlt3.sipsolutions.net> <AANLkTimSqF4D4jPj-HzOjl1vxjf2T7YvlGdR6zcJZ9Pp@mail.gmail.com>
	<1276014816.3706.137.camel@jlt3.sipsolutions.net> <AANLkTilUd2Bp1h4SzlW5f5KevoRM-os_fQrivLHbZyKY@mail.gmail.com>
	<1276250151.3640.11.camel@jlt3.sipsolutions.net> <AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
	<1276507247.3926.13.camel@jlt3.sipsolutions.net> <bug-16215-7251@https.bugzilla.kernel.org/>
	<AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
	<m139wiuswa.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46621 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756748Ab0FTKxM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 06:53:12 -0400
Received: by iwn9 with SMTP id 9so2482336iwn.19
        for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 03:53:12 -0700 (PDT)
In-Reply-To: <m139wiuswa.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 08:20, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
>
> In get_device_parent there is a check to not add a class directory
> when a class device was put under another class device. =C2=A0The che=
ck was
> put in place as a just in case measure to not break old userspace if
> any existing code happened to depend on it. =C2=A0Currently the only =
known
> way that we get a class device under a class device is due to the
> rearrangement of devices that happened when the new sysfs layout was
> introduced.
>
> With the introduction of tagged sysfs directories for properly
> handling network namespace support this omission in creating the clas=
s
> directories went from a bad thing in terms of namespace pollution, to
> actually breaking device_remove.
>
> Currently there are two reported network device drivers that break
> because the class directory was not created by the device layer. =C2=A0=
The
> usb bnep driver and the mac80211_hwsim driver.
>
> Every solution proposed changes the sysfs layout for the affected
> devices, and thus has the potential to break userspace.
>
> Since we are changing the sysfs layout anyway, and since we are now
> talking about several devices all with the same problem, all caused b=
y
> the same over conservative bit of code. =C2=A0Let's kill that bit of =
code.
>
> There have been other proposals to fix this but they all have been
> more complicated, and none of them have actually resulted in working
> code.
>
> Any userspace that works with both the old and the new sysfs layouts
> should not be affected by this change, and even if someone depends
> on it we are talking a very small number of drivers overall that
> are affected.
>
> My apologoies for not fully catching this hole in the logic the
> when this code was originally added.

We can not do this. Simply comparing the sysfs tree before and after
shows that it breaks 'input'. inputX and mouseX are now spearated by a
subdirectory, which is wrong.

As mentioned earlier, It's pretty fragile to change things in this
area, and I prefer the broken network driver-core interactions to be
fixed instead - even when they are more complicated.

Thanks,
Kay
