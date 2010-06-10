From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-2.6] ixgbe: fix automatic LRO/RSC settings for low
	latency
Date: Thu, 10 Jun 2010 13:17:11 -0700
Message-ID: <AANLkTiktWb0gbWOVyQ8pV_JQOnGXPU7dBN0AIwNODXnU@mail.gmail.com>
References: <20100610181204.GO7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>, stable@kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38624 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab0FJUYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 16:24:50 -0400
Received: by gye5 with SMTP id 5so267666gye.19
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 13:24:49 -0700 (PDT)
In-Reply-To: <20100610181204.GO7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 10, 2010 at 11:12, Andy Gospodarek <andy@greyhouse.net> wro=
te:
>
> This patch added to 2.6.34:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0commit f8d1dcaf88bddc7f282722ec1fdddbcb06a=
72f18
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Author: Jesse Brandeburg <jesse.brandeburg=
@intel.com>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Date: =C2=A0 Tue Apr 27 01:37:20 2010 +000=
0
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe: enable extremely low =
latency
>
> introduced a feature where LRO (called RSC on the hardware) was disab=
led
> automatically when setting rx-usecs to 0 via ethtool. =C2=A0Some migh=
t not
> like the fact that LRO was disabled automatically, but I'm fine with
> that. =C2=A0What I don't like is that LRO/RSC is automatically enable=
d when
> rx-usecs is set >0 via ethtool.
>
> This would certainly be a problem if the device was used for forwardi=
ng
> and it was determined that the low latency wasn't needed after the
> device was already forwarding. =C2=A0I played around with saving the =
state of
> LRO in the driver, but it just didn't seem worthwhile and would requi=
re
> a small change to dev_disable_lro() that I did not like.
>
> This patch simply leaves LRO disabled when setting rx-usecs >0 and
> requires that the user enable it again. =C2=A0An extra informational =
message
> will also now appear in the log so users can understand why LRO isn't
> being enabled as they expect.
>
> Inconsistency of LRO setting first noticed by Stanislaw Gruszka.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> CC: Stanislaw Gruszka <sgruszka@redhat.com>
> CC: stable@kernel.org
>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 37 ++++++++---------=
--------------------
> =C2=A01 files changed, 8 insertions(+), 29 deletions(-)
>

Thanks Andy, I have added the patch to my queue.
