From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 14:49:23 +0200
Message-ID: <1319028563.8416.1.camel@edumazet-laptop>
References: <20111019123602.GA11883@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Nico Schottelius <nico-linux-20111017@schottelius.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019123602.GA11883@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 19 octobre 2011 =C3=A0 14:36 +0200, Nico Schottelius a =C3=A9=
crit :
> Hello,
>=20
> I've
>=20
> Eric Dumazet [Tue, Oct 18, 2011 at 02:24:25PM +0200]:
> > Must be a mutex_unlock(some_mltex) missing somewhere.
> >=20
> > Then later, a process holding RTNL is blocking on mutex_lock(some_m=
utex)
> >=20
> > Try a "CONFIG_LOCKDEP=3Dy" enabled build
>=20
> Did so, attached is the dmesg output after 3x suspend.
>=20
> It also seems this bug gets more / only triggered when I loose the
> connection to a wpa2-eap network that is defined like this:
>=20
> network=3D{
>    ssid=3D"eth"
>   id_str=3D"eth-802.2x"
>    key_mgmt=3DWPA-EAP
>    proto=3DWPA2
>    eap=3DTTLS
>    pairwise=3DCCMP TKIP
>    group=3DCCMP TKIP
>    phase2=3D"auth=3DMSCHAPV2"
>    identity=3D"MYNAME"
>    password=3D"forgottoremoveit"
> }
>=20
> Hope the dmesg output helps and we can remove the problem soon
> and making the mba finally almost completly usable :-)
>=20

Sorry, no CONFIG_LOCKDEP in your config or dmesg. Maybe you sent a
previous dmesg/config file ?

Note that you have "CONFIG_LOCKDEP_SUPPORT=3Dy", not "CONFIG_LOCKDEP=3D=
y"
