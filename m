From: Maxime Morin <maxime.morin@vitec.com>
Subject: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Wed, 22 Mar 2017 13:23:41 +0000
Message-ID: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "stsp@list.ru" <stsp@list.ru>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0075.outbound.protection.outlook.com ([104.47.0.75]:41696
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751400AbdCVNY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 09:24:29 -0400
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I work on an embedded platform based on the Marvell Armada 88F6707, that is=
 connected to a Marvell Alaska 88E1512 ethernet transceiver. A defect has a=
ppeared recently, and it turns out to be a regression on the network part. =
There is a complete lost of the network when following these steps:
    1) boot the board with the network cable disconnected
    2) run the following commands (or equivalent):
        ip link set eth0 up
        ip addr add 10.0.0.80/24 dev eth0
        ethtool -s eth0 autoneg on #this is the command that really breaks =
the network
    3) plug the network cable
        =3D> there is no network, and no way to have it back except by rebo=
oting
If I do not launch the "ethtool" command, when I plug the network cable it =
works, so it really seems to be related to the auto-negotiation set to "on"=
 when the network cable has never been connected.
I did a "git bisect" to find when the regression was introduced, because it=
 previously worked with kernel 4.4, but not with the recent ones. The commi=
t that made appear the issue is this one: https://git.kernel.org/pub/scm/li=
nux/kernel/git/torvalds/linux.git/commit/?id=3D0c0744fc1dd5b
If I remove on mvneta.c the part that was added on this commit on the funct=
ion mvneta_ethtool_set_link_ksettings (mvneta_ethtool_set_settings at that =
time), I do not have the issue, but I can't call that a fix...
So, could it be a driver issue, or maybe a wrong configuration somewhere? I=
f you need additional information to reproduce the problem please ask me, I=
 will be as responsive as possible.

Best regards,
Maxime MORIN=
