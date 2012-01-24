From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] Source mode for macvlan interface
Date: Tue, 24 Jan 2012 10:07:37 +0100
Message-ID: <CAGsizzLD=0t_J5m=CdZn8+1j6ZD_Nmz352kydDKDqQKDK5nxSw@mail.gmail.com>
References: <29378065.3471327360294412.JavaMail.root@5-MeO-DMT.ynet.sk> <1327362739.2587.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327362739.2587.15.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/24 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 24 janvier 2012 =E0 00:11 +0100, Stefan Gula a =E9crit :
>> From: Stefan Gula <steweg@gmail.com>
>>
>> New mode of macvlan interface called "source" allows one to specify,
>> which =A0frames are allowed to be received by given macvlan interfac=
e.
>> This logic is used only on received frames on underlying interface.
>> The ability to send frames from macvlan interface through underlying
>> interface is not modified. This feature allows one to simulate 802.1=
x
>> mac based VLAN behavior by using proper netlink message to configure
>> this behavior with utility such as "ip link" from iproute2 suite.
>> This feature allows to create MAC based VLAN associations instead of
>> standard port or tag based, to be able to associate several differen=
t
>> clients/users behind one common port based on their MAC addresses.
>>
>
> Still obscure changelog...
>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>
>
> Please include next time
>
> V3: list of changes
>
>
>
> Why GFP_ATOMIC here ?
changed to GFP_KERNEL

>
> How many 'sources' are expected per port ?
>
> Above a certain (small) threshold, macvlan_fill_info() will 'overflow=
'
> skb capacity and return an error.
>
> Take a look at macvlan_get_size() ?
There should be no defined limits on how many MAC addresses you can
put under one macvlan interface - it should be fully dynamic. You are
right about the function, but I have a difficulty with fixing that. It
is no problem to calculate the space needed to dump all mac-address,
but I tried to check how many times is macvlan_get_size called and it
is called only once per macvlan interface initialization, which is
obviously wrong in my case as I need that number to be changed each
time before fill_info is called. I tried to find and example how to
managed that from other drivers, but I was unsuccessful. Do you have
any idea?
