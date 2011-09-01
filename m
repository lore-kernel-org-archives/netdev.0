From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Thu, 1 Sep 2011 11:37:15 +0200
Message-ID: <CAHXqBFJR=5zTZeq+HnfRp2rb9yX3L=Kjwi_1AyWU2EDqZ=gCWQ@mail.gmail.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
 <1314802836-9862-2-git-send-email-mschmidt@redhat.com> <201108311816.30468.vladz@broadcom.com>
 <20110831175849.328192b8@alice> <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097ADE0@SJEXCHCCR02.corp.ad.broadcom.com>
 <CAHXqBF+f=3yM88CJ+FpNELBb+Sof5q1=pTXm303-QN7y6M9Dsg@mail.gmail.com> <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097B03C@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Schmidt <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40041 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab1IAJhf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 05:37:35 -0400
Received: by iabu26 with SMTP id u26so1699314iab.19
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 02:37:35 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097B03C@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 1 wrze=B6nia 2011 10:37 u=BFytkownik Vladislav Zolotarov
<vladz@broadcom.com> napisa=B3:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Michal Miroslaw
>> Sent: Wednesday, August 31, 2011 9:05 PM
>> To: Vladislav Zolotarov
>> Cc: Michal Schmidt; netdev@vger.kernel.org; Dmitry Kravkov; Eilon
>> Greenstein
>> Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
>>
>> 2011/8/31 Vladislav Zolotarov <vladz@broadcom.com>:
>> >> -----Original Message-----
>> >> From: Michal Schmidt [mailto:mschmidt@redhat.com]
>> >> Sent: Wednesday, August 31, 2011 6:59 PM
>> >> To: Vladislav Zolotarov
>> >> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Eilon Greenstein;
>> >> mirqus@gmail.com
>> >> Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
>> >>
>> >> On Wed, 31 Aug 2011 18:16:30 +0300 Vlad Zolotarov wrote:
>> >> > On Wednesday 31 August 2011 18:00:34 Michal Schmidt wrote:
>> >> > > =A0 if (bnx2x_reload) {
>> >> > > - =A0 =A0 =A0 =A0 if (bp->recovery_state =3D=3D BNX2X_RECOVER=
Y_DONE)
>> >> > > + =A0 =A0 =A0 =A0 if (bp->recovery_state =3D=3D BNX2X_RECOVER=
Y_DONE) {
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Cheat! Normally dev->f=
eatures will be
>> >> > > set after we
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* return, but that's too=
 late. We need to
>> >> > > know how to
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* configure the NIC when=
 reloading it, so
>> >> > > update
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the features early.
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features =3D features;
>> >> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return bnx2x_reload_if_ru=
nning(dev);
>> >> >
>> >> > NACK
>> >> >
>> >> > This is bogus - what if bnx2x_reload_if_running(dev)
>> >> > (bnx2x_nic_load()) failes? The original dev->features would be
>> >> > lost...
>> >>
>> >> Well, yes, but since the NIC would be now not working, do we real=
ly
>> >> care about its features? :-)
>> >
>> > U r kidding, right? ;)
>> > We care about the consistency in the netdev features state - if we
>> failed
>> > to configure the requested feature and returned an error on e.g.
>> "ethtool -K ethX lro on"
>> > call, it's expected that a subsequent ethtool -k ethX call won't
>> report the requested
>> > feature (LRO) as set.
>>
>> If bnx2x_reload_if_running() failure means that NIC is disabled, the=
n
>> Michal is right that there's no point in caring about dev->features,
>> sice 'load' operation (NIC configuration) needs to be done again
>> anyway.
> Michal, it's a matter of a consistent semantics/behavior of the ethto=
ol callbacks just as I described above.
> As long as dev->features may be queried both when device is down I'm =
afraid I can't agree with u.

If I understand correctly, bnx2x_reload_if_running() failure does not
mean exactly that features change failed. It means that device failed
to initialize, possibly because of other (transient?) conditions. So
unless reverting features change and retrying the initialization is
known to allow the device to be brought back, there's no difference
whether old or new dev->features value is kept and which set is
reported by ethtool.

Best Regards,
Micha=B3 Miros=B3aw
