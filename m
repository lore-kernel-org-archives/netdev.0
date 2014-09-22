From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/2] net: bcmgenet: TX reclaim and DMA fixes
Date: Mon, 22 Sep 2014 11:50:05 -0700
Message-ID: <54206F5D.7070000@gmail.com>
References: <1411087697-19306-1-git-send-email-f.fainelli@gmail.com> <20140922.144618.340968117925494461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59650 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbaIVSuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:50:22 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so5052953pad.41
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 11:50:22 -0700 (PDT)
In-Reply-To: <20140922.144618.340968117925494461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2014 11:46 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu, 18 Sep 2014 17:48:15 -0700
>=20
>> This patch set contains one fix for an accounting problem while recl=
aiming
>> transmitted buffers having fragments, and the second fix is to make =
sure
>> that the DMA shutdown is properly controlled.
>=20
> Florian I am seriesly irritated, are you even build testing these
> changes?
>=20
> bcmgenet_dma_teardown() is a static function declared far after the
> new call you are adding in patch #2, so now we get:
>=20
> drivers/net/ethernet/broadcom/genet/bcmgenet.c: In function =E2=80=98=
bcmgenet_fini_dma=E2=80=99:
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:1752:2: error: implici=
t declaration of function =E2=80=98bcmgenet_dma_teardown=E2=80=99 [-Wer=
ror=3Dimplicit-function-declaration]
> drivers/net/ethernet/broadcom/genet/bcmgenet.c: At top level:
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:2111:12: error: static=
 declaration of =E2=80=98bcmgenet_dma_teardown=E2=80=99 follows non-sta=
tic declaration
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:1752:2: note: previous=
 implicit declaration of =E2=80=98bcmgenet_dma_teardown=E2=80=99 was he=
re
>=20
> I want to make it clear to you that whatever time you think you're
> saving by skipping even the most basic compilation test, goes directl=
y
> to _ME_ and you are therefore having a negative impact on every singl=
e
> developer who is also waiting for me to review and integrate their
> networking changes.
>=20
> Please do not do this any more.

Very sorry about that, v2 is on your way, I will be more careful.
--
=46lorian
