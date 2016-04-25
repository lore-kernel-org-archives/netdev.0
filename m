From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 18:34:57 +0200
Message-ID: <CAMuHMdVzeR9iMAJPwZj3HV56XwYcc_+eAhx+YiCN33Do3tsJSg@mail.gmail.com>
References: <1461570761-12187-1-git-send-email-geert@linux-m68k.org>
	<87r3dtybm8.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3dtybm8.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien,

On Mon, Apr 25, 2016 at 5:03 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>> drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_bri=
dge_join=E2=80=99:
>> drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 may=
 be used uninitialized in this function
>
> Interesting, I don't have those warnings on 207afda1b5036009...

It depends on the compiler version (still using 4.1.2) and options.

>> If netdev_notifier_changeupper_info.upper_dev is ever NULL, the brid=
ge
>> parameter will be NULL too, and the function will return an
>> uninitialized value.
>>
>> Pre-initialize err to zero to fix this.
>>
>> Fixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same defaul=
t FDB")
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>> Can this actually happen?
>
> bridge cannot be NULL here. Also ps->ports[port].bridge_dev is assign=
ed
> to it before entering the for loop, so _mv88e6xxx_port_based_vlan_map
> will be called at least for this port.

But there's no way the compiler can know that...

Gr{oetje,eeting}s,

                        Geert
