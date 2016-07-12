From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client
 regression
Date: Tue, 12 Jul 2016 10:32:00 -0400
Message-ID: <20fb5234-63d4-dce3-a6fd-1d943639142c@stressinduktion.org>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
 <20160711.134848.216095848280988851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Valdis.Kletnieks@vt.edu, jonas@lippuner.ca,
	hideaki.yoshifuji@miraclelinux.com
To: David Miller <davem@davemloft.net>, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52728 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754770AbcGLOcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 10:32:06 -0400
In-Reply-To: <20160711.134848.216095848280988851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.07.2016 16:48, David Miller wrote:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Mon, 11 Jul 2016 16:43:50 +0200
>=20
>> The Juniper SSL VPN client use a "tun" interface and seems to
>> be picky about visible changes.to it. Commit cc9da6cc4f56
>> ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
>> made such interfaces get an auto-generated IPv6 link local address
>> by default, similar to most other interface types. This made the
>> Juniper SSL VPN client fail for unknown reasons.
>>
>> Fixing this regression by adding a new private netdevice flag
>> which disables automatic IPv6 link local address generation, and
>> making the flag default for "tun" devices.
>>
>> Setting an explicit addrgenmode will disable the flag, so userspace
>> can choose to enable automatic LL generation by selecting a suitable
>> addrgenmode.
>>
>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D121131
>> Fixes: cc9da6cc4f56 ("ipv6: addrconf: use stable address generator f=
or ARPHRD_NONE")
>> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
>> Reported-by: Jonas Lippuner <jonas@lippuner.ca>
>> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclel=
inux.com>
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>=20
> What really irks me is that we "fixing" something without knowing wha=
t
> actually is the problem.
>=20
> Someone needs to figure out exactly what is making the Juniper thing
> unhappy.  It really shouldn't care if a link local address is assigne=
d
> to the tun device, this is fundamental ipv6 stuff.

I agree, but there could be a lot of factors affecting this. For exampl=
e
we know start to send out an icmp router solicitation into the vpn as
soon as the link goes up, as well as initial mld change record. It coul=
d
very well trigger security software and kill the VPN (something I can
very well imagine right now).

I actually don't suspect something funny going on in the Juniper's Java
client itself, this would just be too strange. Unfortunately I don't
have access to such systems to check what could be the problem.

Bjorn send a list of things that could be tried.

Thanks,
Hannes
