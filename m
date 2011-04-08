From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: extending feature word.
Date: Fri, 8 Apr 2011 12:05:35 +0200
Message-ID: <20110408100535.GB10565@rere.qmqm.pl>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41867 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615Ab1DHKFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 06:05:37 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
> Thanks for your comments on my loop-back patch. I was looking at the
> code today from the perspective of extending various "features" for
> word to an array of words and as Michael has pointed out, it's a huge
> change. So I'm thinking on the following lines
> (include/linux/netdevice.h)
>=20
> +#define DEV_FEATURE_WORDS =A0 =A0 =A02
> +#define LEGACY_FEATURE_WORD =A0 =A00
> =A0 =A0 =A0 =A0/* currently active device features */
> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features[DE=
V_FEATURE_WORDS];
> =A0 =A0 =A0 =A0/* user-changeable features */
> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features=
;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_features=
[DEV_FEATURE_WORDS];
> =A0 =A0 =A0 =A0/* user-requested features */
> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_feat=
ures;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_feat=
ures[DEV_FEATURE_WORDS];
> =A0 =A0 =A0 =A0/* VLAN feature mask */
> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_featur=
es;
> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_featur=
es[DEV_FEATURE_WORDS];

Hmm. There might be no point in making features field an array.
This gives us nothing really. Maybe just add features_2 or similar?
If we ever get to the point there need to be more than two words for
features we can think of some abstraction layer then.

Or we might add a new field and put there NETIF_F_LLTX, NETIF_F_HIGHDMA
and others that are not user changeable ever. Those don't need dynamic
propagation to slave devices (e.g. VLAN) and wanted/hw_features for the=
m.

Best Regards,
Micha=B3 Miros=B3aw
