From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 17/22] platform/x86: alienware-wmi: fix format string
 overflow warning
Date: Fri, 14 Jul 2017 22:18:25 +0300
Message-ID: <CAHp75Vd2eZAj++QdGraspjpTX=VPVR6qY+iCZiHsySGvUcGVmQ@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-18-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Darren Hart <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Platform Driver <platform-driver-x86@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-18-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 3:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> gcc points out a possible format string overflow for a large value of 'zone':
>
> drivers/platform/x86/alienware-wmi.c: In function 'alienware_wmi_init':
> drivers/platform/x86/alienware-wmi.c:461:24: error: '%02X' directive writing between 2 and 8 bytes into a region of size 6 [-Werror=format-overflow=]
>    sprintf(buffer, "zone%02X", i);
>                         ^~~~
> drivers/platform/x86/alienware-wmi.c:461:19: note: directive argument in the range [0, 2147483646]
>    sprintf(buffer, "zone%02X", i);
>                    ^~~~~~~~~~
> drivers/platform/x86/alienware-wmi.c:461:3: note: 'sprintf' output between 7 and 13 bytes into a destination of size 10
>
> While the zone should never be that large, it's easy to make the
> buffer a few bytes longer so gcc can prove this to be safe.

Please, be a bit smarter on such fixes.

Here we need to convert

int i;

to

u8 i;

I will take it after addressing above.

P.S. You may do this change across the file.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/platform/x86/alienware-wmi.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/platform/x86/alienware-wmi.c b/drivers/platform/x86/alienware-wmi.c
> index 0831b428c217..acc01242da82 100644
> --- a/drivers/platform/x86/alienware-wmi.c
> +++ b/drivers/platform/x86/alienware-wmi.c
> @@ -421,7 +421,7 @@ static DEVICE_ATTR(lighting_control_state, 0644, show_control_state,
>  static int alienware_zone_init(struct platform_device *dev)
>  {
>         int i;
> -       char buffer[10];
> +       char buffer[13];
>         char *name;
>
>         if (interface == WMAX) {
> --
> 2.9.0
>



-- 
With Best Regards,
Andy Shevchenko
