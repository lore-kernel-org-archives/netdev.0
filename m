From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] [RFC] net: dsa: mv88e6xxx: Pre-initialize err in mv88e6xxx_port_bridge_join()
Date: Mon, 25 Apr 2016 13:31:09 -0400
Message-ID: <87vb35a942.fsf@ketchup.mtl.sfl>
References: <1461570761-12187-1-git-send-email-geert@linux-m68k.org> <87r3dtybm8.fsf@ketchup.mtl.sfl> <CAMuHMdVzeR9iMAJPwZj3HV56XwYcc_+eAhx+YiCN33Do3tsJSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48036 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619AbcDYRbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:31:13 -0400
In-Reply-To: <CAMuHMdVzeR9iMAJPwZj3HV56XwYcc_+eAhx+YiCN33Do3tsJSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> On Mon, Apr 25, 2016 at 5:03 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>>> drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_port_br=
idge_join=E2=80=99:
>>> drivers/net/dsa/mv88e6xxx.c:2184: warning: =E2=80=98err=E2=80=99 ma=
y be used uninitialized in this function
>>
>> Interesting, I don't have those warnings on 207afda1b5036009...
>
> It depends on the compiler version (still using 4.1.2) and options.
>
>>> If netdev_notifier_changeupper_info.upper_dev is ever NULL, the bri=
dge
>>> parameter will be NULL too, and the function will return an
>>> uninitialized value.
>>>
>>> Pre-initialize err to zero to fix this.
>>>
>>> Fixes: 207afda1b5036009 ("net: dsa: mv88e6xxx: share the same defau=
lt FDB")
>>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>> ---
>>> Can this actually happen?
>>
>> bridge cannot be NULL here. Also ps->ports[port].bridge_dev is assig=
ned
>> to it before entering the for loop, so _mv88e6xxx_port_based_vlan_ma=
p
>> will be called at least for this port.
>
> But there's no way the compiler can know that...

Or maybe it can in new configurations. Anyway, this fix doesn't hurt,
with a relevant commit message, I'd ack it.

Thanks,

        Vivien
