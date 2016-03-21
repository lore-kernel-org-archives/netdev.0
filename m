From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 09:36:01 +0100
Message-ID: <1458549361.2299.1.camel@suse.com>
References: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-03-20 at 11:43 +0100, Geert Uytterhoeven wrote:
> If CONFIG_PM=3Dn:
>=20
>     drivers/net/usb/lan78xx.c: In function =E2=80=98lan78xx_get_stats=
64=E2=80=99:
>     drivers/net/usb/lan78xx.c:3274: error: =E2=80=98struct dev_pm_inf=
o=E2=80=99 has no
> member named =E2=80=98runtime_auto=E2=80=99
>=20
> If PM is disabled, the runtime_auto flag is not available, but auto
> suspend is not enabled anyway.  Hence protect the check for
> runtime_auto
> by #ifdef CONFIG_PM to fix this.
>=20
> Fixes: a59f8c5b048dc938 ("lan78xx: add ndo_get_stats64")
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Alternatively, we can add a dev_pm_runtime_auto_is_enabled() wrapper
> to
> include/linux/pm.h, which always return false if CONFIG_PM is
> disabled.

That is what we do for almost everything else in include/pm_runtime.h
So it is the best solution to add the stub.

	Regards
		Oliver


