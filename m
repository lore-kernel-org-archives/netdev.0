From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH net-next 00/11] convert stmmac glue layers into platform
 drivers
Date: Fri, 15 May 2015 09:45:47 +0200
Message-ID: <5555A42B.3040205@st.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
 <CAGb2v663efjkwgRjPdxV4CQxeesiu7jxkMf9j_oPU_bSHbNNiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, b.galvani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Roger <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 dinguyen-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arnd
 Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CAGb2v663efjkwgRjPdxV4CQxeesiu7jxkMf9j_oPU_bSHbNNiA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello

On 5/14/2015 5:24 PM, Chen-Yu Tsai wrote:
> On Thu, May 14, 2015 at 6:10 PM, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> This patch set aims to convert the current dwmac glue layers into
>> proper platform drivers as request by Arnd[1]. These changes start
>> from patch 3 and onwards.
>>
>> Overview:
>> Platform driver functions like probe and remove are exported from
>> the stmmac platform and then used in subsequent glue later
>> conversions. The conversion involes adding the platform driver
>> boiler plate code and adding it to the build system. The last patch
>> removes the driver from the stmmac platform code thus making it into
>> a library for common platform driver functions.
>>
>> The two first patches adds glue layer for my platform. I chose to
>> first add old style glue layer and then convert it. The churn this
>> creates is just 3 lines.
>>
>> I would be very nice if people could test this patch set on their
>> respective platform. My testing has been limited to compiling and
>> testing on my (LPC18xx) platform. Thanks!

I wonder if this will make the compatibility with old
platforms (like SH4) not based on DT, where there was not used
any glue-logic around the driver and just the platform was the
reference.

To be honest, I prefer to not have the Kconfig options.
The device-tree compatibility will select the glue-logic
needed and we will just pay some bytes when compile.

In my opinion, the Koption(s) introduce a problem when touch
the driver and we want to guarantee that, at least,
all its parts build fine on all the platforms.

Regards,
Peppe

>
> Tested-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>
> on sunxi boards Cubietruck and Hummingbird A31.
>
>> Next I will look into cleaning up the stmmac platform code.
>>
>> [1] http://marc.info/?l=linux-arm-kernel&m=143059524606459&w=2
>>
>> Joachim Eastwood (11):
>>    stmmac: add dwmac glue for NXP 18xx/43xx family
>>    doc: dt: add documentation for nxp,lpc1850-dwmac
>>    stmmac: prepare stmmac platform to support stand alone drivers
>>    stmmac: add a generic dwmac driver
>>    stmmac: convert dwmac-lpc18xx to a platform driver
>>    stmmac: convert dwmac-meson to platform driver
>>    stmmac: convert dwmac-rk to platform driver
>>    stmmac: convert dwmac-socfpga to platform driver
>>    stmmac: convert dwmac-sti to platform driver
>>    stmmac: convert dwmac-sunxi to platform driver
>>    stmmac: drop driver from stmmac platform code
>>
>>   .../devicetree/bindings/net/nxp,lpc1850-dwmac.txt  | 20 +++++
>>   drivers/net/ethernet/stmicro/stmmac/Kconfig        | 76 +++++++++++++++++
>>   drivers/net/ethernet/stmicro/stmmac/Makefile       | 13 ++-
>>   .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 41 +++++++++
>>   .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 99 ++++++++++++++++++++++
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 24 +++++-
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 27 +++++-
>>   .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 21 ++++-
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 29 ++++++-
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 25 +++++-
>>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 49 ++---------
>>   .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  9 +-
>>   12 files changed, 378 insertions(+), 55 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
>>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
>>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
>>
>> --
>> 1.8.0
>>
>
