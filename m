From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Always create class directories fixing the
	broken network drivers.
Date: Sun, 20 Jun 2010 13:46:20 +0200
Message-ID: <AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com>
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
	<m139wiuswa.fsf_-_@fess.ebiederm.org> <AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
	<1277033628.3642.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45201 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab0FTLqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 07:46:35 -0400
Received: by iwn9 with SMTP id 9so2502886iwn.19
        for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 04:46:35 -0700 (PDT)
In-Reply-To: <1277033628.3642.1.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 13:33, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Sun, 2010-06-20 at 12:52 +0200, Kay Sievers wrote:
>
>> As mentioned earlier, It's pretty fragile to change things in this
>> area, and I prefer the broken network driver-core interactions to be
>> fixed instead - even when they are more complicated.
>
> Can you _please_ offer a proper way to fix it then?

Sorry, I have no real experience with the issues created by the
assumption that network driver need to be able to get unloaded while
in use. That's very special, always requires a
compiled-into-the-kernel part of the subsystem, and makes it hard to
work with, as we can not use any of the usual core infrastructure to
solve that.

The only real simple thing that works is splitting the module in two
modules, which isn't really something I would propose.

Maybe the wait-for in the module-exit like your recent mail suggests
works, but I did not try that. Otherwise we can solve this by changing
the net driver and by adding some needed stuff to the core to allow
in-core bus device cleanup.

The class device hierarchy should be removed for proper network
namespace support, it's nothing we properly support with the current
core code. We better don't fiddle around with stuff nobody really
knows what it breaks. Just like I ran into the 'input' stuff now,
which was a really simple case to find.

Kay
