From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Bug#660804: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 08:48:53 -0500
Message-ID: <20120223084853.2110605c@thirdoffive.cmf.nrl.navy.mil>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	<20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	<4F4528CE.7080702@linuxsystems.it>
	<4F458F82.3060808@linuxsystems.it>
	<1329961083.15610.2.camel@edumazet-laptop>
	<1329962079.15610.6.camel@edumazet-laptop>
Reply-To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>, 660804@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Niccol=C3=B2?= Belli <darkbasic@linuxsystems.it>,
        Stephen
 Hemminger <shemminger@vyatta.com>,
        Linux Networking Developer Mailing List
  <netdev@vger.kernel.org>,
        openadsl-users@lists.sourceforge.net,
        openadsl-devel@lists.sourceforge.net, support@traverse.com.au,
        support@rocksolidelectronics.com, 660804@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.660804.B660804.133000503831695@bugs.debian.org>
In-Reply-To: <1329962079.15610.6.camel@edumazet-laptop>
List-URL: <http://lists.debian.org/debian-kernel/>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Thu, 23 Feb 2012 02:54:39 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 02:38 +0100, Eric Dumazet a =C3=A9cr=
it :
>=20
> > Which driver handles this Traverse Solos card ?
>=20
> If br2684_push() is used, it seems it lacks proper call to
> skb_reset_mac_header(skb) in paths where eth_type_trans() is not called.
>=20
> Later in xfrm4_mode_tunnel_input() we crash because we assume
> skb_mac_header() is valid.

when br2684_push() doesnt call eth_type_trans() the underlying packet
doesnt have a mac address header -- just an llc header that says 'ip
packet is next'.
