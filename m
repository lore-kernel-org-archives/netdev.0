From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [regression] ath5k: Overrides regulatory domain set for cfg80211
Date: Fri, 10 Jul 2009 13:43:12 +0200
Message-ID: <200907101343.14113.elendil@planet.nl>
References: <200907082340.07787.elendil@planet.nl> <200907090311.40205.elendil@planet.nl> <43e72e890907081907j279f48eep99e73cc2951dfdb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890907081907j279f48eep99e73cc2951dfdb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks again for your elaborate explanation Louis.

On Thursday 09 July 2009, Luis R. Rodriguez wrote:
> EU is a valid regulatory domain only when the relic option
> CONFIG_WIRELESS_OLD_REGULATORY is used. When you use OLD_REG and "EU"
> you get stuck to a statically defined regulatory domain in the kernel=
=2E
>
> > =C2=A0[Now I specify NL and it gives me US; how's that an improveme=
nt?]
>
> Since you are using OLD_REG the default is "US", that was the behavio=
r
> prior to the new regulatory code so its left as is. So that is by
> design following the old crap regulatory code design.
>
> > cfg80211: Calling CRDA for country: NL
> > =C2=A0[no agent, so this does not actually change anything]
>
> Users of OLD_REG who do not have new userspace should stick to using
> the 3 static regulatory domains:
>
>   1) US *
>   2) JP
>   3) EU

Right, so the EU I had originally was correct after all :-)

> >> For further information please also read
> >> Documentation/feature-removal-schedule.txt. Please use a valid
> >> ISO-3166 alpha2 country code, I also advise to abandon the usage o=
f
> >> the ieee80211_regdom module parameter which we do eventually inten=
d
> >> on deprecating and if you know anyone using that please suggest th=
e
> >> same.
> >
> > As mentioned above I do not currently have the option of abandoning
> > it.
>
> Yes you do, but you don't seem to want to do anything beyond what you=
r
> distribution offers, which is different.

You're right :-)
However, I am also a Debian Developer and Debian may (just as we did fo=
r=20
Etch), at some point want to offer a newer kernel than the current .26=20
for stable (possibly .31). From that PoV it is important to ensure ther=
e=20
are no incompatibilities with what's in Debian stable.
=46or that reason I am very conservative when it comes to installer new=
er or=20
backported versions of packages.

> > That seems particularly bad in my case. For some weird reason this
> > Trust PCMCIA card seems to have AM in its EEPROM, which is Armenia.=
=2E.
> > The card was bought in the Netherlands (NL), which is also where I
> > live.
>
> Yeah the short story of that is Armenia and Netherlands both have the
> same regulatory rules, the first alpha2 that matched the same group
> was picked up, which just so happened to be Armenia. In the future it
> will be easier if cards are just programmed with the alpha2 country
> code or with a world regulatory domain code, and just abandon the
> grouping idea. That is something we will have to look forward to
> change and promote for future device. What counts for regulatory
> purposes is your device is complaint. The alternative was to keep all
> the regulatory information statically in the kernel for each
> regulatory group for Atheros devices.

Ah! I had no idea about that and I guess that this is the real issue he=
re:=20
a simple usability problem. If I had seen the correct countrycode (NL=20
instead of AM), I probably never would have reported a regression. What=
=20
prompted my mail was that, from a user PoV, the country being selected=20
looked to be completely broken. How am I, as a simple user, supposed to=
=20
know that Armenia uses the same domain as the Netherlands and that what=
=20
the driver is doing is actually 100% correct (and even that my PCMCIA=20
card is not as broken as I thought)?

Would it be possible to improve the info presented by the kernel? Maybe=
=20
print an extra line with a list of countries that use the selected reg=20
domain (depends I guess on what's the max. nr. of countries that share =
a=20
domain). Or at least indicate that the country code is a somewhat rando=
m=20
choice.

> > I can to some extend understand respecting hardware settings for AP=
s,
> > but for a wireless NIC it seems a useless limitation.
>
> You are right to a certain degree. The thing is wireless cards *can*
> be used as APs on a regular desktops. Perhaps not with iwlagn, but
> with ath5k and ath9k you can do AP, IBSS, Mesh, all of which actually
> do start transmit with out any AP being around. For these cases you
> *do* need to ensure proper regulatory compliance. And we haven't even
> touched on DFS!

Well, IIUC you do know what mode the card is being used in, so in theor=
y=20
you could distinguish between them. I'm not pushing for that though.

End conclusion is that there is no regression and no backwards=20
compatibility issue (which is good news), just a usability issue.

Thanks,
=46JP
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
