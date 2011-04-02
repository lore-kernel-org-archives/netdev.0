From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: extending feature word.
Date: Sat, 2 Apr 2011 14:42:07 +0200
Message-ID: <20110402124207.GB3147@rere.qmqm.pl>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60904 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012Ab1DBMmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 08:42:09 -0400
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
> +#define legacy_features =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features[LEGA=
CY_FEATURE_WORD]
> +#define legacy_hw_features =A0 =A0 hw_features[LEGACY_FEATURE_WORD]
> +#define legacy_wanted_features wanted_features[LEGACY_FEATURE_WORD]
> +#define=A0legacy_vlan_features =A0 =A0vlan_features[LEGACY_FEATURE_W=
ORD]
>=20
>=20
> So that it will be a matter of -
>=20
> s/features/legacy_features/
> s/hw_features/legacy_hw_features/
> s/wanted_features/legacy_wanted_features/
> s/vlan_features/legacy_vlan_features/
>=20
> to start with as a first step. Once this is done, legacy_* can be
> changed with respective arrays and modified as per the need. Comments=
?

You could just s/features/features[0]/ as well. Why the extra hiding?

If you want to split the work, it would be clearer to first convert
hw_features and wanted_features (with all the core code touching it -
this is the easy part), then vlan_features (this includes drivers'
and VLAN code) and then features (it's all over).

Best Regards,
Micha=B3 Miros=B3aw
