From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Fri, 10 Jul 2015 11:22:52 -0700
Message-ID: <55A00D7C.9090807@gmail.com>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru> <559EBC59.6020003@gmail.com> <559EDD0C.7020907@list.ru> <559EE45C.4040408@gmail.com> <559EEAE9.4000806@list.ru> <alpine.LNX.2.02.1507100940530.15010@sbrk.org> <559FAA71.2030209@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>, Sebastien Rannou <mxs@sbrk.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559FAA71.2030209@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/15 04:20, Stas Sergeev wrote:
> 10.07.2015 11:46, Sebastien Rannou =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On Fri, 10 Jul 2015, Stas Sergeev wrote:
>>
>>> 10.07.2015 00:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> Then, if the in-band status indication is not reliable (which real=
ly
>>>> should be completely understood),
>>> Agree!
>>> But this is not something I can help with.
>>> Sebastien Rannou reports the problem, please ask him whatever
>>> you see fits to get a better understanding of a problem.
>>> The fact that his HW does not generate the inband status, is
>>> _my own guess_.
>>
>> Yes, I confirm that my HW does not generate an in-band status. AFAIK=
, it's
>> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY=
 (with
>> inband status) is connected to the switch through QSGMII, and in thi=
s context
>> we are on the media side of the PHY.
> Hmm, interesting.
> So if I parse the above correctly, you have something like 88E1340S s=
et
> up into a mode when SGMII is used as media interface and QSGMII as sy=
stem
> interface (terms are from datasheet page 5), then you connect the med=
ia
> interface to armada-xp and system interface to the switch.
>=20
> I wonder if it is the right thing to do.
> AFAIK you could as well set up armada-xp into QSGMII mode and connect
> that to switch. The driver would then disable the use of inband statu=
s
> and everything would be fine.
> Either way, your use-case proves that only DT can decide the use of a=
n
> inband status.

I do not think there is any debate around the need for a property that
defines whether in-band-status is both reliable and usable, the debate
is about *where* to put it.

I still think this does not belong in the fixed-link property, but now
that you have explained a bit more in the other patch what your
understanding of "fixed-link" is, I can see the confusion.

Instead of having a link =3D "auto", property, how about just something
like this:

fixed-link {
	speed =3D <1000>;
	full-duplex;
	use-in-band-status;
};

or event this:

fixed-link {
	use-in-band-status;
};

If you parse the 'use-in-band-status' which means that it is reliable
information, then you can override whatever was defined in the DT under
the 'fixed-link' property?
--=20
=46lorian
