From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 11:03:11 -0400
Message-ID: <87r3dtybm8.fsf@ketchup.mtl.sfl>
References: <1461570761-12187-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461570761-12187-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_brid=
ge_join=E2=80=99:
> drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 may =
be used uninitialized in this function

Interesting, I don't have those warnings on 207afda1b5036009...

> If netdev_notifier_changeupper_info.upper_dev is ever NULL, the bridg=
e
> parameter will be NULL too, and the function will return an
> uninitialized value.
>
> Pre-initialize err to zero to fix this.
>
> Fixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same default=
 FDB")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Can this actually happen?

bridge cannot be NULL here. Also ps->ports[port].bridge_dev is assigned
to it before entering the for loop, so _mv88e6xxx_port_based_vlan_map
will be called at least for this port.

Thanks,

        Vivien
