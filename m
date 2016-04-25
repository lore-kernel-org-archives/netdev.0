From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 19:53:39 +0200
Message-ID: <CAMuHMdVfYTx3CCa0GnqmcWHBQPYZZUYZQz1hOOaUjgXFmhVP3w@mail.gmail.com>
References: <1461570761-12187-1-git-send-email-geert@linux-m68k.org>
	<87r3dtybm8.fsf@ketchup.mtl.sfl>
	<CAMuHMdVzeR9iMAJPwZj3HV56XwYcc_+eAhx+YiCN33Do3tsJSg@mail.gmail.com>
	<87vb35a942.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vb35a942.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien,

On Mon, Apr 25, 2016 at 7:31 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>> On Mon, Apr 25, 2016 at 5:03 PM, Vivien Didelot
>> <vivien.didelot@savoirfairelinux.com> wrote:
>>> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>>>> drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_b=
ridge_join=E2=80=99:
>>>> drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 m=
ay be used uninitialized in this function
>>>
>>> Interesting, I don't have those warnings on 207afda1b5036009...
>>
>> It depends on the compiler version (still using 4.1.2) and options.
>>
>>>> If netdev_notifier_changeupper_info.upper_dev is ever NULL, the br=
idge
>>>> parameter will be NULL too, and the function will return an
>>>> uninitialized value.
>>>>
>>>> Pre-initialize err to zero to fix this.
>>>>
>>>> Fixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same defa=
ult FDB")
>>>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>>> ---
>>>> Can this actually happen?
>>>
>>> bridge cannot be NULL here. Also ps->ports[port].bridge_dev is assi=
gned
>>> to it before entering the for loop, so _mv88e6xxx_port_based_vlan_m=
ap
>>> will be called at least for this port.
>>
>> But there's no way the compiler can know that...
>
> Or maybe it can in new configurations. Anyway, this fix doesn't hurt,
> with a relevant commit message, I'd ack it.

What would you consider a relevant commit message?

Thanks!

Gr{oetje,eeting}s,

                        Geert
