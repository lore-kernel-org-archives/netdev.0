From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] net: drop NETIF_F_GSO from hw_features without NETIF_F_SG
Date: Sat, 19 Mar 2011 17:18:17 +0100
Message-ID: <AANLkTinCdaEs=G=AC45ePA-J99Vik9fYE+ZyF1miCiVy@mail.gmail.com>
References: <20110318195030.GA22350@core.hellgate.ch> <AANLkTim1_+GdURWxk=+N+5xCFTF1L27BD=+Uu+BY4jWF@mail.gmail.com>
 <20110319074653.GA12820@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45998 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702Ab1CSQSi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 12:18:38 -0400
Received: by qyk7 with SMTP id 7so1550543qyk.19
        for <netdev@vger.kernel.org>; Sat, 19 Mar 2011 09:18:37 -0700 (PDT)
In-Reply-To: <20110319074653.GA12820@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/19 Roger Luethi <rl@hellgate.ch>:
> On Fri, 18 Mar 2011 21:43:23 +0100, Micha? Miros?aw wrote:
>> 2011/3/18 Roger Luethi <rl@hellgate.ch>:
>> > register_netdevice() removes NETIF_F_GSO from dev->features and
>> > dev->wanted_features for hardware without NETIF_F_SG to "avoid war=
ning from
>> > netdev_fix_features()".
>> >
>> > However, as the flag remains set in dev->hw_features, users trying=
 to
>> > enable GSO via ethtool will still end up with NETIF_F_GSO stuck in
>> > wanted_features, resulting in a warning every time they try to cha=
nge any
>> > feature (until they use ethtool to "disable" GSO):
>>
>> That's expected, as it allows the user to debug why his request didn=
't
>> work as expected. I think that those messages should get demoted to
>> DEBUG if that's too noisy. The network core imposed conditions could
>> be explained in Documentation/ or ethtool manpage instead.
>
> I agree that it is good to have a note explaining what happened in th=
e
> kernel log, and the patch I posted does not do that; that is easy to =
fix.
>
> However, I still think the current, unpatched behavior is confusing u=
sers.
> ethtool_get_features() will happily tell the user that GSO is availab=
le for
> a NIC even if it is not (because the NIC does not support SG). Then, =
if the
> user tries to enable GSO, the operation fails silently: ethtool won't=
 get
> an error code, so it looks as if the operation succeeded. The user ne=
eds to
> look into the kernel log or actually verify the offload settings to r=
ealize
> that something went wrong.

Actually, the user will get the information that GSO wasn't enabled,
though not while using ETHTOOL_SGSO.

OTOH, I think I can see what's your point - I got confused by your
proposed patch. The correct way is to remove NETIF_F_GSO from
hw_features when NETIF_F_SG is not present in hw_features (and not
wanted_features as you're patch is doing). The idea here is that a
driver might advertise SG in changeable features (that's hw_features)
but not enable it by default for whatever reason.

Do you want to prepare a patch for this? Please remember about
compatibility with per-offload ethtool ops if you do - this needs to
be there until all drivers are converted to hw_features.

Best Regards,
Micha=C5=82 Miros=C5=82aw
