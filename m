From: <Mario.Limonciello@dell.com>
Subject: RE: [PATCH 17/22] platform/x86: alienware-wmi: fix format string
 overflow warning
Date: Fri, 14 Jul 2017 18:30:25 +0000
Message-ID: <3eaa1de8d1074c96a9491a823a6a4af2@ausx13mpc120.AMER.DELL.COM>
References: <20170714120720.906842-1-arnd@arndb.de>
 <20170714120720.906842-18-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: <gregkh@linuxfoundation.org>, <torvalds@linux-foundation.org>,
        <linux@roeck-us.net>, <akpm@linux-foundation.org>,
        <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <jejb@linux.vnet.ibm.com>, <martin.petersen@oracle.com>,
        <linux-scsi@vger.kernel.org>, <x86@kernel.org>,
        <arvind.yadav.cs@gmail.com>, <platform-driver-x86@vger.kernel.org>
To: <arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
        <dvhart@infradead.org>, <andy@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-18-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Friday, July 14, 2017 7:07 AM
> To: linux-kernel@vger.kernel.org; Darren Hart <dvhart@infradead.org>; And=
y
> Shevchenko <andy@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>; Linus Torvalds
> <torvalds@linux-foundation.org>; Guenter Roeck <linux@roeck-us.net>;
> akpm@linux-foundation.org; netdev@vger.kernel.org; David S . Miller
> <davem@davemloft.net>; James E . J . Bottomley <jejb@linux.vnet.ibm.com>;
> Martin K . Petersen <martin.petersen@oracle.com>; linux-scsi@vger.kernel.=
org;
> x86@kernel.org; Arnd Bergmann <arnd@arndb.de>; Limonciello, Mario
> <Mario_Limonciello@Dell.com>; Arvind Yadav <arvind.yadav.cs@gmail.com>;
> platform-driver-x86@vger.kernel.org
> Subject: [PATCH 17/22] platform/x86: alienware-wmi: fix format string ove=
rflow
> warning
>=20
> gcc points out a possible format string overflow for a large value of 'zo=
ne':
>=20
> drivers/platform/x86/alienware-wmi.c: In function 'alienware_wmi_init':
> drivers/platform/x86/alienware-wmi.c:461:24: error: '%02X' directive writ=
ing
> between 2 and 8 bytes into a region of size 6 [-Werror=3Dformat-overflow=
=3D]
>    sprintf(buffer, "zone%02X", i);
>                         ^~~~
> drivers/platform/x86/alienware-wmi.c:461:19: note: directive argument in =
the
> range [0, 2147483646]
>    sprintf(buffer, "zone%02X", i);
>                    ^~~~~~~~~~
> drivers/platform/x86/alienware-wmi.c:461:3: note: 'sprintf' output betwee=
n 7 and
> 13 bytes into a destination of size 10
>=20
> While the zone should never be that large, it's easy to make the
> buffer a few bytes longer so gcc can prove this to be safe.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/platform/x86/alienware-wmi.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/platform/x86/alienware-wmi.c
> b/drivers/platform/x86/alienware-wmi.c
> index 0831b428c217..acc01242da82 100644
> --- a/drivers/platform/x86/alienware-wmi.c
> +++ b/drivers/platform/x86/alienware-wmi.c
> @@ -421,7 +421,7 @@ static DEVICE_ATTR(lighting_control_state, 0644,
> show_control_state,
>  static int alienware_zone_init(struct platform_device *dev)
>  {
>  	int i;
> -	char buffer[10];
> +	char buffer[13];
>  	char *name;
>=20
>  	if (interface =3D=3D WMAX) {
> --
> 2.9.0

LGTM,  Thanks.

Signed-off-by: Mario Limonciello <mario.limonciello@dell.com>
