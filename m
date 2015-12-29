From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] /drivers/net/wireless/ath/ath9k remove unnecessary ?:
 operator
Date: Mon, 28 Dec 2015 16:31:24 -0800
Message-ID: <1451349084.3219.19.camel@perches.com>
References: <20151228134852.GA10572@alpha.sfu-kras.ru>
	 <1451325412.3219.12.camel@perches.com> <5681818A.9060406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ivan Safonov <insafonov@gmail.com>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0200.hostedemail.com ([216.40.44.200]:39758 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752813AbbL2Ab1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 19:31:27 -0500
In-Reply-To: <5681818A.9060406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-29 at 01:38 +0700, Ivan Safonov wrote:
> On 12/29/2015 12:56 AM, Joe Perches wrote:
> > On Mon, 2015-12-28 at 20:48 +0700, Ivan Safonov wrote:
> > > ((thermometer < 0) ? 0 : (thermometer =3D=3D X)) and (thermometer=
 =3D=3D
> > > X) are equal for X >=3D 0.
> > X is not guaranteed to be >=3D 0 here
>=20
> X is fixed constant. In this case X is {0, 1, 2}.

Looks like it can be -1 to me (range: -1, 0, 1, 2)

static int ar9003_hw_get_thermometer(struct ath_hw *ah)
{
	struct ar9300_eeprom *eep =3D &ah->eeprom.ar9300_eep;
	struct ar9300_base_eep_hdr *pBase =3D &eep->baseEepHeader;
	int thermometer =3D=A0=A0(pBase->miscConfiguration >> 1) & 0x3;

	return --thermometer;
}
