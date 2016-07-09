From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Sun, 10 Jul 2016 01:23:55 +0200
Message-ID: <8737niqttg.fsf@miraculix.mork.no>
References: <1468098791-20420-1-git-send-email-bjorn@mork.no>
	<1468102772.3805579.661647841.59799999@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Jonas Lippuner <jonas@lippuner.ca>,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59576 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932155AbcGIXYN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 19:24:13 -0400
In-Reply-To: <1468102772.3805579.661647841.59799999@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Sun, 10 Jul 2016 00:19:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On Sat, Jul 9, 2016, at 23:13, Bj=C3=B8rn Mork wrote:
>> The Juniper SSL VPN client use a "tun" interface and seems to
>> be picky about visible changes.to it. Commit cc9da6cc4f56
>> ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
>> made such interfaces get an auto-generated IPv6 link local address
>> by default, similar to most other interface types. This made the
>> Juniper SSL VPN client fail for unknown reasons.
>>=20
>> Fixing this regression by effectively reverting the behaviour to
>> what we had before, while keeping the new "addrgenmode random"
>> feature.
>
> I wonder if we can simply add a flag, something like
> IFF_SUPPRESS_AUTO_IPV6_LL, to net_device->priv_flags and use that. So=
 we
> can keep behavior for qmi, vxlan-gpe and gre. tun is the only device
> that is really user space facing, so maybe we just limit it to this?

Sounds good to me, but I don't know if the use case really qualifies as

 "* You should have a pretty good reason to be extending these flags."


The automatic address is certainly nice to have, but "good reason"?  I
don't know...  We can always just configure those devices for automatic
LL addresses using "ip link set foo addrgen random" or similar.


Bj=C3=B8rn
