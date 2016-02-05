From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Fri, 05 Feb 2016 16:07:12 +0100
Message-ID: <1454684832.2779.10.camel@v3.sk>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
	 <8166.1452616452@famine> <1452619189.18559.83.camel@v3.sk>
	 <20160112.154914.397367508465928770.davem@davemloft.net>
	 <87bn8qv5m4.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jay.vosburgh@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bn8qv5m4.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi=C2=A0Bj=C3=B8rn,

On Tue, 2016-01-12 at 22:40 +0100, Bj=C3=B8rn Mork wrote:
> David Miller <davem@davemloft.net> writes:
> > From: Lubomir Rintel <lkundrak@v3.sk>
> > Date: Tue, 12 Jan 2016 18:19:49 +0100
> >=20
> > > It's still an improvement to let the distributions decide if
> > > they're
> > > keeping "ip link add" broken or possibly affecting the scripts.
> >=20
> > That it is "broken" is your opinion.
> >=20
> > Document the behavior.=C2=A0=C2=A0It is not broken if the user is t=
old to be
> > mindful of what devices are created by default.
> >=20
> > There is way too much downside to changing this.
>=20
> Besides, distributions or admins can already change that behaviour if
> they consider it "broken", using the existing module parameter:
>=20
> =C2=A0# echo "options bonding max_bonds=3D0" >/etc/modprobe.d/bonding=
=2Econf
> =C2=A0# rmmod bonding
> =C2=A0# ip link add bond0 type bond
> =C2=A0(no error here)
>=20
> This method should be well known and understood by most users,
> contrary
> to some odd CONFIG_ build time setting.

Yes, that's an alternative solution. We may end up shipping such
configuration file, though it's not really clear what package should
ship it (probably systemd?).

I'd still prefer a kernel build-time option. It's more likely for
distributions to do the decision they prefer when running make
oldconfig. I'm assuming most distros would like to drop the legacy
behavior; at this point noone probably relies on it anyway, given
NetworkManager works around this by manually loading the module with
the maxbonds=3D0 manually.

Also, there's prior art to addressing this in kernel; the block
loopback.

> Bj=C3=B8rn

Regards,
Lubo
