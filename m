From: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 1/6] ARM: davinci: da850: fix clock lookup for mdio
 device
Date: Sun, 3 Feb 2013 17:08:37 +0530
Message-ID: <CA+V-a8vJrx_x97VjHjAuVuY_+=uSq=vR00Z-rL-9Z_BcCE1sEw@mail.gmail.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
 <1359380879-26306-2-git-send-email-prabhakar.lad@ti.com>
 <510E469D.9020807@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Lad,
 Prabhakar" <prabhakar.lad-l0cyMroinI0@public.gmane.org>, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <510E469D.9020807-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Sekhar,

On Sun, Feb 3, 2013 at 4:44 PM, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org> wrote:
> On 1/28/2013 7:17 PM, Prabhakar Lad wrote:
>> From: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
>>
>> This patch removes the clock alias for mdio device and adds a entry
>> in clock lookup table, this entry can now be used by both DT and NON
>> DT case.
>>
>> Signed-off-by: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
>> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>> Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
>> Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
>> ---
>>  arch/arm/mach-davinci/da850.c         |    1 +
>>  arch/arm/mach-davinci/devices-da8xx.c |    8 ++------
>>  2 files changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/arm/mach-davinci/da850.c b/arch/arm/mach-davinci/da850.c
>> index 86056ca..f74bfb6 100644
>> --- a/arch/arm/mach-davinci/da850.c
>> +++ b/arch/arm/mach-davinci/da850.c
>> @@ -402,6 +402,7 @@ static struct clk_lookup da850_clks[] = {
>>       CLK(NULL,               "arm",          &arm_clk),
>>       CLK(NULL,               "rmii",         &rmii_clk),
>>       CLK("davinci_emac.1",   NULL,           &emac_clk),
>> +     CLK("davinci_mdio.0",   "fck",          &emac_clk),
>>       CLK("davinci-mcasp.0",  NULL,           &mcasp_clk),
>>       CLK("da8xx_lcdc.0",     "fck",          &lcdc_clk),
>>       CLK("davinci_mmc.0",    NULL,           &mmcsd0_clk),
>> diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
>> index 2d5502d..52faa05 100644
>> --- a/arch/arm/mach-davinci/devices-da8xx.c
>> +++ b/arch/arm/mach-davinci/devices-da8xx.c
>> @@ -444,12 +444,8 @@ int __init da8xx_register_emac(void)
>>       ret = platform_device_register(&da8xx_mdio_device);
>>       if (ret < 0)
>>               return ret;
>> -     ret = platform_device_register(&da8xx_emac_device);
>> -     if (ret < 0)
>> -             return ret;
>> -     ret = clk_add_alias(NULL, dev_name(&da8xx_mdio_device.dev),
>> -                         NULL, &da8xx_emac_device.dev);
>> -     return ret;
>> +
>> +     return platform_device_register(&da8xx_emac_device);
>
> You added the look-up only for DA850 which means after this patch da830
> network will be broken. Did you test on DA830?

Ah yes my bad this will break network on da830, I'll fix it and respin
this patch
alone only, if there aren't any comments for the rest of the series.

Regards,
--Prabhakar


> Thanks,
> Sekhar
