From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next ] Fix time-lag of IFF_RUNNING flag consistency
 between vlan and real devices
Date: Thu, 25 Aug 2011 23:08:59 -0700
Message-ID: <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgk1pcm9zxYJhdw==?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45666 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692Ab1HZGIv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 02:08:51 -0400
In-Reply-To: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2011 15:02:57 +0900
Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:

> There is a time-lag of IFF_RUNNING flag consistency between vlan and =
real
> devices when the real devices are in problem such as link or cable br=
oken.
> This leads to a degradation of Availability such as a delay of failov=
er in
> HA systems using vlan since the detection of the problem at real devi=
ce is
> delayed.
>=20
> Why this happens:
> Network devices' flags can be checked using ioctl with SIOCGIFFLAGS. =
When
> vlan technique is used, it checks the flags of vlan device, not real
> device.
>=20
> Patch:
> This patch adds vlan-device check into dev_get_flags(). So, it can ch=
eck
> flags of the real device even if the vlan is used.
>=20
> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Jesse Gross <jesse@nicira.com>

I don't think this is the right way to solve the problem.

The flags are supposed to propagate back from real device to vlan
via network notifications.

Just doing this for ioctl is not enough, API's other than user space de=
pend on this.
Also the user may have manually set different flags on vlan than on
the real device.
