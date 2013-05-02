From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 13:55:42 -0400 (EDT)
Message-ID: <20130502.135542.1332946768988319212.davem@davemloft.net>
References: <1367512467.4000.7.camel@dcbw.foobar.com>
	<20130502.133947.387694205526879673.davem@davemloft.net>
	<CAHXqBF+Xb0ZVo2tO-0m59JJDrwy5vYX6=jLbts_ZAv5Pk+7SCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mirqus@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHXqBF+Xb0ZVo2tO-0m59JJDrwy5vYX6=jLbts_ZAv5Pk+7SCw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Thu, 2 May 2013 19:47:25 +0200

> 2013/5/2 David Miller <davem@davemloft.net>:
>> From: Dan Williams <dcbw@redhat.com>
>> Date: Thu, 02 May 2013 11:34:27 -0500
>>
>>> On Wed, 2013-05-01 at 18:28 -0700, Linus Torvalds wrote:
>>>> On Wed, May 1, 2013 at 1:47 PM, David Miller <davem@davemloft.net>=
 wrote:
>>>> >
>>>> > Highlights (1721 non-merge commits, this has to be a record of s=
ome
>>>> > sort):
>>>>
>>>> Lowlight: it completely breaks my machine with r8169 ethernet.  In=
 the
>>>> networkmanager applet, it claims no cable connection, which is a b=
it
>>>> odd, because (a) it works with an older kernel and (b) the kernel
>>>> messages actually say
>>>>
>>>>   r8169 0000:01:00.0 eth0: link up
>>>
>>> NM calls ETHTOOL_GLINK and if that returns success, NM expects the
>>> driver to support carrier detection.  NM then listens to netlink fo=
r
>>> device flags changes, and uses IFF_LOWER_UP to determine carrier on=
/off
>>> state.  NM does not use NETIF_F_VLAN_CHALLENGED or any of the other
>>> ETHTOOL_GFEATURES flags yet, but will in the future.
>>>
>>> Is the link status accurately reflected by /sys/class/net/eth0/carr=
ier ?
>> Something cares about the .../eth0/flags value because with the bit
>> ordering different for bits 10 and above things break.
>=20
> Are you sure it's "flags"? /sys/class/net/*/features were removed som=
e
> time ago, and flags don't depend on NETIF_F_*.

Oh, it's flags, which is printed in raw hex by net/core/net-sysfs.c:

NETDEVICE_SHOW(flags, fmt_hex);
