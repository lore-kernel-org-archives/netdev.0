From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: fix netns ops ordering on module load/unload
Date: Wed, 03 Feb 2010 18:11:32 -0800 (PST)
Message-ID: <20100203.181132.194298727.davem@davemloft.net>
References: <20100130125327.GA4258@x200>
	<68676e01002010550l2654208dged864973a996c381@mail.gmail.com>
	<1265032590.2848.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kronos.it@gmail.com, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753020Ab0BDCLS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 21:11:18 -0500
In-Reply-To: <1265032590.2848.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 Feb 2010 14:56:30 +0100

> Le lundi 01 f=E9vrier 2010 =E0 14:50 +0100, Luca Tettamanti a =E9crit=
 :
>> On Sat, Jan 30, 2010 at 1:53 PM, Alexey Dobriyan <adobriyan@gmail.co=
m> wrote:
>=20
>> > [PATCH] af_key: fix netns ops ordering on module load/unload
>> >
>> > 1. After sock_register() returns, it's possible to create sockets,
>> >   even if module still not initialized fully (blame generic module=
 code
>> >   for that!)
>> > 2. Consequently, pfkey_create() can be called with pfkey_net_id st=
ill not
>> >   initialized which will BUG_ON in net_generic():
>> >        kernel BUG at include/net/netns/generic.h:43!
>> > 3. During netns shutdown, netns ops should be unregistered after
>> >   key manager unregistered because key manager calls can be trigge=
red
>> >   from xfrm_user module:
>> >
>> >        general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEA=
LLOC
>> >        pfkey_broadcast+0x111/0x210 [af_key]
>> >        pfkey_send_notify+0x16a/0x300 [af_key]
>> >        km_state_notify+0x41/0x70
>> >        xfrm_flush_sa+0x75/0x90 [xfrm_user]
>> > 4. Unregister netns ops after socket ops just in case and for symm=
etry.
>> >
>> > Reported by Luca Tettamanti.
>> >
>> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>>=20
>> Tested-by: Luca Tettamanti <kronos.it@gmail.com>
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone!
