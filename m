From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wl3501_cs: avoid bogus gcc-6 warning
Date: Thu, 16 Jun 2016 15:06:54 +0000 (UTC)
Message-ID: <20160616150654.83BA46141C@smtp.codeaurora.org>
References: <4731273.LDpWBaOjNT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57016 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbcFPPGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:06:55 -0400
In-Reply-To: <4731273.LDpWBaOjNT@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:
> gcc-6 on x86 started warning about wl3501_get_encode when building
> with -O2:
>=20
> drivers/net/wireless/wl3501_cs.c: In function =E2=80=98wl3501_get_enc=
ode=E2=80=99:
> drivers/net/wireless/wl3501_cs.c:1769:5: warning: =E2=80=98implemente=
d=E2=80=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1686:19: warning: =E2=80=98threshold=
=E2=80=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1702:20: warning: =E2=80=98threshold=
=E2=80=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1719:23: warning: =E2=80=98txpow=E2=80=
=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1752:20: warning: =E2=80=98retry=E2=80=
=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1806:25: warning: =E2=80=98pwr_state=
=E2=80=99 may be used uninitialized in this function
> drivers/net/wireless/wl3501_cs.c:1383:24: warning: =E2=80=98value=E2=80=
=99 may be used uninitialized in this function
>=20
> I could not figure out what exactly confuses gcc here, but splitting =
the
> wl3501_get_mib_value function into two helps the compiler to figure o=
ut
> that the variables are not actually used uninitialized, and makes it
> slightly clearer to a human reader what the function actually does an=
d
> which parts of it are under the spinlock.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, 1 patch applied to wireless-drivers-next.git:

2683f7dd9aad wl3501_cs: avoid bogus gcc-6 warning

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9138643/
