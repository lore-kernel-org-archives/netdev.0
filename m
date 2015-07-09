From: Stas Sergeev <stsp@list.ru>
Subject: Re: [5/6] mvneta: implement SGMII-based in-band link state signaling
Date: Thu, 09 Jul 2015 13:11:10 +0300
Message-ID: <559E48BE.5010801@list.ru>
References: <55155D9D.6070800@list.ru>	<alpine.LNX.2.02.1507081757260.28659@sbrk.org>	<559D5520.3030700@list.ru>	<alpine.LNX.2.02.1507091040530.23853@sbrk.org> <20150709111941.6a49091f@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastien Rannou <mxs@sbrk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp31.i.mail.ru ([94.100.177.91]:59399 "EHLO smtp31.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbbGIKLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 06:11:18 -0400
In-Reply-To: <20150709111941.6a49091f@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

09.07.2015 12:19, Thomas Petazzoni =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Sebastien, Stas,
>=20
> On Thu, 9 Jul 2015 11:03:26 +0200 (CEST), Sebastien Rannou wrote:
>> On Wed, 8 Jul 2015, Stas Sergeev wrote:
>>
>>> What is there? A phy chip, or something else?
>>
>> It's "something else", there's a phy which aggregates 4xSGMIIs to
>> 1xQSGMII, we are on the media side here, the MAC side is connected
>> to the switch through QSGMII.
>>
>>> Perhaps some DT property should be added to explicitly
>>> enable the use of the inband status...
>>
>> Yes, that would be fine.
>=20
> Isn't it a bit weird to need a new DT property for this? Shouldn't
> fixed-link always imply this inband status thing?
That's how it is currently implemented. I thought its safe.
But what if the device on the other end does not generate the
inband status? I think this device is doing the wrong thing,
but nevertheless we have a regression at hands.

Currently the link status cannot be specified for fixed-link,
at all.
What I am going to code up, is the new property, like this:

fixed-link {
  link =3D "up" | "down" | "auto";
};

"auto" will mean the inband status.
Looks like a simple solution.
