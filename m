From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 00/10] ARM: STi: Add dwmac glue and reset controller
Date: Tue, 19 Nov 2013 06:28:42 +0100
Message-ID: <528AF70A.7080603@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<stephen.gallimore@st.com>, <linux-kernel@vger.kernel.org>,
	<kernel@stlinux.com>, <linux-pm@vger.kernel.org>
To: <srinivas.kandagatla@st.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12/2013 2:51 PM, srinivas.kandagatla@st.com wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>
> Hi All,
>
> This patch series adds Ethernet support to STi series SOCs STiH415 and STiH416.
> STi SOC series integrates dwmac IP from synopsis, however there is a hardware
> glue on top of this standard IP, this glue needs to configured before the
> actual dwmac can be used.
> To add this a new driver dwmac-sti is introduced whose responsibility is to
> configure dwmac glue and before dwmac driver, this is achieved by making dwmac
> device node as child to ethernet glue node. Inspired by usb/dwc3.
> Also the glue needs to come out of softreset which is why we have added a
> softreset controller to driver which looked perfectly neat, rather then
> driving the softreset bit from the glue driver.
>
> Also as part of power management in glue driver, I found that there was no
> function to determine if the child device is a wakeup source or not.
> I have added a new api device_child_may_wakeup API which could be useful for
> drivers like this. "PM / wakeup : Introduce device_child_may_wakeup" patch has
> that new API and "net: stmmac:sti: Add STi SOC glue driver." glue driver uses
> this new API.
>
> The reason for combining all these patches in a same series is because of
> dependencies.
>
> This patch series is tested on B2000 and B2020 boards with STiH415, STiH416
> SOC on ethernet 100/1000 Links.
>
> Comments?

Hello Srini
ll these patches are ok for me and, as you know, I have already started
using them while porting other SoC. Glue logic is mandatory now!

Thanks
peppe

>
> Thanks,
> srini
>
> Srinivas Kandagatla (6):
>    drivers: reset: stih415: add softreset controller
>    drivers: reset: stih416: add softreset controller
>    PM / wakeup : Introduce device_child_may_wakeup
>    net: stmmac:sti: Add STi SOC glue driver.
>    ARM: STi: Add STiH415 ethernet support.
>    ARM: STi: Add STiH416 ethernet support.
>
> Stephen Gallimore (4):
>    drivers: reset: STi SoC system configuration reset controller support
>    drivers: reset: Reset controller driver for STiH415
>    drivers: reset: Reset controller driver for STiH416
>    ARM: STi: Add reset controller support to mach-sti Kconfig
>
>   .../devicetree/bindings/net/sti-dwmac.txt          |   45 +++
>   .../devicetree/bindings/reset/st,sti-powerdown.txt |   46 +++
>   .../devicetree/bindings/reset/st,sti-softreset.txt |   45 +++
>   arch/arm/boot/dts/stih415-clock.dtsi               |   14 +
>   arch/arm/boot/dts/stih415-pinctrl.dtsi             |   82 ++++++
>   arch/arm/boot/dts/stih415.dtsi                     |   67 +++++
>   arch/arm/boot/dts/stih416-clock.dtsi               |   14 +
>   arch/arm/boot/dts/stih416-pinctrl.dtsi             |  106 +++++++
>   arch/arm/boot/dts/stih416.dtsi                     |   69 +++++
>   arch/arm/boot/dts/stih41x-b2000.dtsi               |   32 +++
>   arch/arm/boot/dts/stih41x-b2020.dtsi               |   33 +++
>   arch/arm/mach-sti/Kconfig                          |    3 +
>   drivers/base/power/wakeup.c                        |   23 ++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  294 ++++++++++++++++++++
>   drivers/reset/Kconfig                              |    2 +
>   drivers/reset/Makefile                             |    3 +
>   drivers/reset/sti/Kconfig                          |   15 +
>   drivers/reset/sti/Makefile                         |    4 +
>   drivers/reset/sti/reset-stih415.c                  |   99 +++++++
>   drivers/reset/sti/reset-stih416.c                  |  101 +++++++
>   drivers/reset/sti/reset-syscfg.c                   |  186 ++++++++++++
>   drivers/reset/sti/reset-syscfg.h                   |   69 +++++
>   .../dt-bindings/reset-controller/stih415-resets.h  |   23 ++
>   .../dt-bindings/reset-controller/stih416-resets.h  |   25 ++
>   include/linux/pm_wakeup.h                          |    1 +
>   26 files changed, 1402 insertions(+), 0 deletions(-)
>   create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
>   create mode 100644 Documentation/devicetree/bindings/reset/st,sti-powerdown.txt
>   create mode 100644 Documentation/devicetree/bindings/reset/st,sti-softreset.txt
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
>   create mode 100644 drivers/reset/sti/Kconfig
>   create mode 100644 drivers/reset/sti/Makefile
>   create mode 100644 drivers/reset/sti/reset-stih415.c
>   create mode 100644 drivers/reset/sti/reset-stih416.c
>   create mode 100644 drivers/reset/sti/reset-syscfg.c
>   create mode 100644 drivers/reset/sti/reset-syscfg.h
>   create mode 100644 include/dt-bindings/reset-controller/stih415-resets.h
>   create mode 100644 include/dt-bindings/reset-controller/stih416-resets.h
>

