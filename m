From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [regression] ath5k: Overrides regulatory domain set for cfg80211
Date: Wed, 8 Jul 2009 19:07:17 -0700
Message-ID: <43e72e890907081907j279f48eep99e73cc2951dfdb@mail.gmail.com>
References: <200907082340.07787.elendil@planet.nl> <43e72e890907081508n6fa5781an1dcbda078efc5379@mail.gmail.com>
	<200907090311.40205.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907090311.40205.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 8, 2009 at 6:11 PM, Frans Pop<elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org> wrote:

>> First, its not that anything is being ignored, user input is always
>> welcomed to help compliance you are just using a wrong ISO-3166
>> alpha2.
>>
>> EU is not a country and as such is only left on older kernels with
>> CONFIG_WIRELESS_OLD_REGULATORY =C2=A0enabled. So "EU" is deprecated =
for non
>> CONFIG_WIRELESS_OLD_REGULATORY based kernels now.
>
> I *do* have CONFIG_WIRELESS_OLD_REGULATORY set for exactly the reason=
 that
> I know I don't yet have the new userland.

That was the purpose for it after all.

> And if I change the country code to NL, I still get the same problem:
> cfg80211: Using static regulatory domain info
> cfg80211: Regulatory domain: US
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(start_freq - end_freq @ bandwidth), (max_=
antenna_gain, max_eirp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(2402000 KHz - 2472000 KHz @ 40000 KHz), (=
600 mBi, 2700 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5170000 KHz - 5190000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5190000 KHz - 5210000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5210000 KHz - 5230000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5230000 KHz - 5330000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5735000 KHz - 5835000 KHz @ 40000 KHz), (=
600 mBi, 3000 mBm)
> =C2=A0[Weird, when I specified EU I at least got the EU domain here.]

EU is a valid regulatory domain only when the relic option
CONFIG_WIRELESS_OLD_REGULATORY is used. When you use OLD_REG and "EU"
you get stuck to a statically defined regulatory domain in the kernel.

> =C2=A0[Now I specify NL and it gives me US; how's that an improvement=
?]

Since you are using OLD_REG the default is "US", that was the behavior
prior to the new regulatory code so its left as is. So that is by
design following the old crap regulatory code design.

> cfg80211: Calling CRDA for country: NL
> =C2=A0[no agent, so this does not actually change anything]

Users of OLD_REG who do not have new userspace should stick to using
the 3 static regulatory domains:

  1) US *
  2) JP
  3) EU

Unfortunately, the default is "US".

> ath5k 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> ath5k 0000:02:00.0: registered as 'phy0'
> ath: EEPROM regdomain: 0x30
> ath: EEPROM indicates we should expect a direct regpair map
> ath: Country alpha2 being used: AM
> ath: Regpair used: 0x30
> phy0: Selected rate control algorithm 'minstrel'
> ath5k phy0: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
> ath5k phy0: RF2112B 2GHz radio found (0x46)
> cfg80211: Calling CRDA for country: AM
> =C2=A0[no agent, so this does not actually change anything]

Yes, by default you world roam when using an Atheros device and no
userspace agent is available. This is by design. ath5k previously used
to allow every single channel, restricting these further is not a
regression but more a regulatory fix on Linux. Its what allows us
vendors like Atheros to support Linux. For further information please
refer to:

http://wireless.kernel.org/en/vendors/VendorSupport
http://wireless.kernel.org/en/developers/Regulatory

>> For further information please also read
>> Documentation/feature-removal-schedule.txt. Please use a valid
>> ISO-3166 alpha2 country code, I also advise to abandon the usage of
>> the ieee80211_regdom module parameter which we do eventually intend =
on
>> deprecating and if you know anyone using that please suggest the sam=
e.
>
> As mentioned above I do not currently have the option of abandoning i=
t.

Yes you do, but you don't seem to want to do anything beyond what your
distribution offers, which is different.

Users of OLD_REG with Atheros devices will world roam because we do
care about regulatory compliance.

> Please continue to provide full backwards compatibility with "old"
> userland until all major distros have iw and crda in their stable
> releases.

That's already done. You are missing the big picture, that of proper
regulatory compliance. Fixing regulatory compliance is not a
regression, it means more devices get proper support in Linux and more
vendors can be attracted to do the same.

>> Eventually, as you will read from the feature-removal schedule, we
>> intend on getting the Linux desktop to provide automatic hints of th=
e
>> user's location through things like GeoClue. Reason for removing the
>> module parameter is its not the proper way to pass information to th=
e
>> kernel, we now have a netlink interface for this exact purpose. Unti=
l
>> the desktop catches up we'll keep the ieee80211_regdom module
>> parameter, but the proper new way to set your regulatory domain as a
>> user is through iw [1] which does use netlink. Some distributions
>> (like Fedora) automatically set your country based on the timezone
>> information. So in the end you should not have to do this at all as =
a
>> user.
>
> Excellent for the future, but not yet an option for me.
>
>> Another thing you should note is that if a driver has a regulatory
>> domain hint then the driver regulatory domain is always trusted, use=
rs
>> can *further* help compliance by selecting their country. What this
>> means since Atheros drivers do have EEPROM reading for the regulator=
y
>> domain that will be used first, thus enabling only channels allowed =
by
>> the programmed EEPROM.
>
> That seems particularly bad in my case. For some weird reason this Tr=
ust
> PCMCIA card seems to have AM in its EEPROM, which is Armenia...
> The card was bought in the Netherlands (NL), which is also where I li=
ve.

Yeah the short story of that is Armenia and Netherlands both have the
same regulatory rules, the first alpha2 that matched the same group
was picked up, which just so happened to be Armenia. In the future it
will be easier if cards are just programmed with the alpha2 country
code or with a world regulatory domain code, and just abandon the
grouping idea. That is something we will have to look forward to
change and promote for future device. What counts for regulatory
purposes is your device is complaint. The alternative was to keep all
the regulatory information statically in the kernel for each
regulatory group for Atheros devices.

> I have no idea what the regulations are in Armenia, but it seems damn=
ed
> silly to me to be restricted in this way just because of random hardw=
are
> manufacturer's settings. I thought in the Linux world we'd long accep=
ted
> that hardware manufacturers can't be trusted to get such things right=
=2E

The world of Linux with wireless is in its diapers when it comes to
regulatory compliance, we just started. And a key feature to
regulatory compliance with today's legislation is to trust the
device's origin. As stupid as it may seem -- current legislation puts
vendors in positions to assume that some devices will never go to
another country. The law is obviously outdated but companies cannot
simply start being flexible without legislation actually changing.

What we are doing with Linux is paving the way for the future for a
decent regulatory infrastructure which makes sense and allows dynamic
communication and roaming. Slowly the hope is legislation will catch
on.

> Even ignoring the completely valid case of someone buying hardware in=
 one
> country and then moving to another one.

Yes, I agree this is silly as well, but legislation needs to be
respected. Devices which have potential to roam to different countries
tend to get custom world regulatory domains assigned to them.

We have a good world roaming infrastructure with cfg80211 now, but you
have to kiss OLD_REG goodbye to use it.

> I can to some extend understand respecting hardware settings for APs,=
 but
> for a wireless NIC it seems a useless limitation.

You are right to a certain degree. The thing is wireless cards *can*
be used as APs on a regular desktops. Perhaps not with iwlagn, but
with ath5k and ath9k you can do AP, IBSS, Mesh, all of which actually
do start transmit with out any AP being around. For these cases you
*do* need to ensure proper regulatory compliance. And we haven't even
touched on DFS!

> And I also suspect that
> manufacturers of (cheap) NICs are much more likely to get the hardwar=
e
> setting wrong (basically by not caring).

Sure, which is why we did the work we did on Linux. Regardless of how
sloppy the wireless vendors are today Linux has IMHO the best
regulatory infrastructure of all OSes. Nice thing about it too is most
of it is licensed under a permissive license so even the people in
Redmond could actually pick up a few things or two (yeah right)

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
