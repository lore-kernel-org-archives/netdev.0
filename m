From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Wed, 31 Aug 2011 20:05:20 +0200
Message-ID: <CAHXqBF+f=3yM88CJ+FpNELBb+Sof5q1=pTXm303-QN7y6M9Dsg@mail.gmail.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
 <1314802836-9862-2-git-send-email-mschmidt@redhat.com> <201108311816.30468.vladz@broadcom.com>
 <20110831175849.328192b8@alice> <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097ADE0@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Schmidt <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62022 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208Ab1HaSFl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 14:05:41 -0400
Received: by iabu26 with SMTP id u26so986391iab.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 11:05:41 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097ADE0@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/31 Vladislav Zolotarov <vladz@broadcom.com>:
>> -----Original Message-----
>> From: Michal Schmidt [mailto:mschmidt@redhat.com]
>> Sent: Wednesday, August 31, 2011 6:59 PM
>> To: Vladislav Zolotarov
>> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Eilon Greenstein;
>> mirqus@gmail.com
>> Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
>>
>> On Wed, 31 Aug 2011 18:16:30 +0300 Vlad Zolotarov wrote:
>> > On Wednesday 31 August 2011 18:00:34 Michal Schmidt wrote:
>> > > =C2=A0 if (bnx2x_reload) {
>> > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (bp->recovery_state =3D=3D BNX2=
X_RECOVERY_DONE)
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (bp->recovery_state =3D=3D BNX2=
X_RECOVERY_DONE) {
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
* Cheat! Normally dev->features will be
>> > > set after we
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
* return, but that's too late. We need to
>> > > know how to
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
* configure the NIC when reloading it, so
>> > > update
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
* the features early.
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
*/
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->f=
eatures =3D features;
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 r=
eturn bnx2x_reload_if_running(dev);
>> >
>> > NACK
>> >
>> > This is bogus - what if bnx2x_reload_if_running(dev)
>> > (bnx2x_nic_load()) failes? The original dev->features would be
>> > lost...
>>
>> Well, yes, but since the NIC would be now not working, do we really
>> care about its features? :-)
>
> U r kidding, right? ;)
> We care about the consistency in the netdev features state - if we fa=
iled
> to configure the requested feature and returned an error on e.g. "eth=
tool -K ethX lro on"
> call, it's expected that a subsequent ethtool -k ethX call won't repo=
rt the requested
> feature (LRO) as set.

If bnx2x_reload_if_running() failure means that NIC is disabled, then
Michal is right that there's no point in caring about dev->features,
sice 'load' operation (NIC configuration) needs to be done again
anyway.

Best Regards,
Micha=C5=82 Miros=C5=82aw
