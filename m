From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 15:05:29 +0200
Message-ID: <1319029529.8416.3.camel@edumazet-laptop>
References: <20111019123602.GA11883@schottelius.org>
	 <1319028563.8416.1.camel@edumazet-laptop> <4E9EC96E.8020303@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nico Schottelius <nico-linux-20111017-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E9EC96E.8020303-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 19 octobre 2011 =C3=A0 14:58 +0200, Arend van Spriel a =C3=A9=
crit :
> On 10/19/2011 02:49 PM, Eric Dumazet wrote:
> > Le mercredi 19 octobre 2011 =C3=A0 14:36 +0200, Nico Schottelius a =
=C3=A9crit :
> >> Hello,
> >>
> >> I've
> >>
> >> Eric Dumazet [Tue, Oct 18, 2011 at 02:24:25PM +0200]:
> >>> Must be a mutex_unlock(some_mltex) missing somewhere.
> >>>
> >>> Then later, a process holding RTNL is blocking on mutex_lock(some=
_mutex)
> >>>
> >>> Try a "CONFIG_LOCKDEP=3Dy" enabled build
> >>
> >> Did so, attached is the dmesg output after 3x suspend.
> >>
> >> It also seems this bug gets more / only triggered when I loose the
> >> connection to a wpa2-eap network that is defined like this:
> >>
> >> network=3D{
> >>    ssid=3D"eth"
> >>   id_str=3D"eth-802.2x"
> >>    key_mgmt=3DWPA-EAP
> >>    proto=3DWPA2
> >>    eap=3DTTLS
> >>    pairwise=3DCCMP TKIP
> >>    group=3DCCMP TKIP
> >>    phase2=3D"auth=3DMSCHAPV2"
> >>    identity=3D"MYNAME"
> >>    password=3D"forgottoremoveit"
> >> }
> >>
> >> Hope the dmesg output helps and we can remove the problem soon
> >> and making the mba finally almost completly usable :-)
> >>
> >=20
> > Sorry, no CONFIG_LOCKDEP in your config or dmesg. Maybe you sent a
> > previous dmesg/config file ?
> >=20
> > Note that you have "CONFIG_LOCKDEP_SUPPORT=3Dy", not "CONFIG_LOCKDE=
P=3Dy"
> >=20
>=20
> Hi Eric,
>=20
> Are there any configuration setting needed that CONFIG_LOCKDEP depend=
s on?



config LOCKDEP
        bool
        depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE=
_SUPPORT && LOCKDEP_SUPPORT
        select STACKTRACE
        select FRAME_POINTER if !MIPS && !PPC && !ARM_UNWIND && !S390 &=
& !MICROBLAZE
        select KALLSYMS
        select KALLSYMS_ALL

make menuconfig
 -> Kernel hacking
   -> Lock debugging: prove locking correctness



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
