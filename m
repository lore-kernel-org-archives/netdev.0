From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 14:35:14 -0400
Message-ID: <87oa8xtu3h.fsf@ketchup.mtl.sfl>
References: <1461570761-12187-1-git-send-email-geert@linux-m68k.org> <87r3dtybm8.fsf@ketchup.mtl.sfl> <CAMuHMdVzeR9iMAJPwZj3HV56XwYcc_+eAhx+YiCN33Do3tsJSg@mail.gmail.com> <87vb35a942.fsf@ketchup.mtl.sfl> <CAMuHMdVfYTx3CCa0GnqmcWHBQPYZZUYZQz1hOOaUjgXFmhVP3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVfYTx3CCa0GnqmcWHBQPYZZUYZQz1hOOaUjgXFmhVP3w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> Hi Vivien,
>
> On Mon, Apr 25, 2016 at 7:31 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>>> On Mon, Apr 25, 2016 at 5:03 PM, Vivien Didelot
>>> <vivien.didelot@savoirfairelinux.com> wrote:
>>>> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>>>>> drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_=
bridge_join=E2=80=99:
>>>>> drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 =
may be used uninitialized in this function
>>>>
>>>> Interesting, I don't have those warnings on 207afda1b5036009...
>>>
>>> It depends on the compiler version (still using 4.1.2) and options.
>>>
>>>>> If netdev_notifier_changeupper_info.upper_dev is ever NULL, the b=
ridge
>>>>> parameter will be NULL too, and the function will return an
>>>>> uninitialized value.
>>>>>
>>>>> Pre-initialize err to zero to fix this.
>>>>>
>>>>> Fixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same def=
ault FDB")
>>>>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>>>> ---
>>>>> Can this actually happen?
>>>>
>>>> bridge cannot be NULL here. Also ps->ports[port].bridge_dev is ass=
igned
>>>> to it before entering the for loop, so _mv88e6xxx_port_based_vlan_=
map
>>>> will be called at least for this port.
>>>
>>> But there's no way the compiler can know that...
>>
>> Or maybe it can in new configurations. Anyway, this fix doesn't hurt=
,
>> with a relevant commit message, I'd ack it.
>
> What would you consider a relevant commit message?

bridge being NULL is not the reason why err can eventually get returned
uninitialized. The GCC version would be great too, I have no such
warning here with 5.3.0.

Thanks,
-v
