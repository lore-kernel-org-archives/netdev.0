From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Multicast snooping fixes and suggestions
Date: Wed, 23 Feb 2011 19:16:17 -0800
Message-ID: <4D65CD81.4070203@zytor.com>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/15/2011 03:19 PM, Linus L=C3=BCssing wrote:
> Hello everyone,
>=20
> While testing the (very awesome!) bridge igmp/mld snooping support I =
came across
> two issues which are breaking IPv6 multicast snooping and IPv6
> non-link-local multicast on bridges with multicast snooping support e=
nabled
> in general. The first two patches shall fix these issues.
>=20
> The third one addresses a potential bug on little endian machines whi=
ch I noticed
> during this little code reviewing. This patch is untested though, fee=
dback welcome.
>=20
> The fourth and fifth patch are a suggestion to also permit using the =
bridge multicast
> snooping feature for link local multimedia multicast traffic. Therefo=
re
> using the transient multicast flag instead of the non-link-local scop=
e criteria
> seems to be a suitable solution at least for IPv6, in my opinion. Let=
 me know what
> you think about it.
>=20

Hello,

I have just noticed that when using a Linux bridge, IPv6 often fails to
configure until some considerable time has passed, presumably some kind
of retry timer.  The dmesg shows:

[178292.449300] br0: port 1(eth0) entering learning state
[178292.449304] br0: port 1(eth0) entering learning state
[178302.536098] br0: no IPv6 routers present
[178307.416139] br0: port 1(eth0) entering forwarding state

=2E.. even though there is a configured and active IPv6 router on the n=
etwork.

I have also seen some serious delays with DHCPv4 which presumably is du=
e
to lost packets during bridge learning.

Are these packets likely to address that situation (or am I just plain
doing something stupid)?

	-hpa

--=20
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
