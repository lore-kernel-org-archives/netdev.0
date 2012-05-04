From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v3 0/7] ARM: davinci: add support for the am1808 based
 enbw_cmc board
Date: Sat, 5 May 2012 00:06:21 +0530
Message-ID: <4FA421A5.4020109@ti.com>
References: <1330945804-3379-1-git-send-email-hs@denx.de> <4FA3F6C2.9010602@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	<linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>, Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>,
	Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
To: <hs-ynQEQJNshbs@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FA3F6C2.9010602-ynQEQJNshbs@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Heiko,

On 5/4/2012 9:03 PM, Heiko Schocher wrote:
> Hello,
> 
> this v3 patchset is now pending for more than 1 month without
> seeing comments for it. Are there no more issues?

I am yet to get to them. I have mostly cleared my backlog and will be
looking into these next. Sorry about the delay.

> Should I rebase it (if no further comments occur), as it is
> pending so long? (If so, against which tree?)

The series touches multiple subsystems, so may be each patch will go
through individual subsystem maintainer.

Also copying Grant and Rob as device tree maintainers.

Thanks,
Sekhar

> 
> Thanks.
> 
> bye,
> Heiko
> 
> Heiko Schocher wrote:
>> This patchserie add support for the davinci am1808 based
>> enbw_cmc board.
>>
>> Important: I rebased this patchserie against the irqdomain/next
>> branch from grant likely, as he suggested to rework the OF
>> intcontroller changes to the irqdomain work, branch found here:
>>
>> http://git.secretlab.ca/?p=linux-2.6.git;a=shortlog;h=refs/heads/irqdomain/next
>>
>>     git://git.secretlab.ca/git/linux-2.6.git irqdomain/next
>>
>>     commit 280ad7fda5f95211857fda38960f2b6fdf6edd3e
>>     Author: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
>>     Date:   Fri Feb 24 14:58:54 2012 -0700
>>
>>     mfd: twl-core: Add IRQ_DOMAIN dependency
>>
>> changes for v2:
>> Post this patchserie now as v2, as reworked in the
>> comments I got for the RFC serie.
>>
>> changes for v3:
>> - Interrupt Controller:
>>   - comment from Sergei Shtylyov:
>>     - rename compatible" prop to "ti,cp_intc"
>>     - cp_intc_init() is now also for the of case
>>       the name of the init function (it calls the
>>       "new" __cp_intc_init() function, which was
>>       the "old" cp_intc_init()). Through this
>>       rework the changes for OF is better visible.
>>       As the OF case uses the irq_domain rework from
>>       Grant Likely, maybe the none OF case can use
>>       this also, but this should be tested on a hw ...
>>  
>> Got no comments to the following points, I noted in the
>> RFC series, so posting this patchseries with them:
>>
>> - ARM: davinci: configure davinci aemif chipselects through OF
>>   not moved to mfd, as mentioned in this discussion:
>>   http://davinci-linux-open-source.1494791.n2.nabble.com/PATCH-arm-davinci-configure-davinci-aemif-chipselects-through-OF-td7059739.html
>>   instead use a phandle in the DTS, so drivers which
>>   uses the davinci aemif, can call davinci_aemif_setup_timing_of()
>>
>>   This is just thought as an RFC ... The enbw_cmc board
>>   support not really need to setup this bus timings, as
>>   they are setup in U-Boot ... but I want to post this,
>>   as I think, it is a nice to have, and I am not really
>>   sure, if this has to be a MFD device (If so, all bus
>>   interfaces for other SoCs should be converted also to
>>   MFD devices) ... as an example how this can be used
>>   I add this to the davinci nand controller OF support
>>   patch, in this patchserie.
>>
>> - ARM: davinci: mux: add OF support
>>   I want to get rid of the pin setup code in board code ...
>>   This patch introduces a davinci_cfg_reg_of() function,
>>   which davinci drivers can call, if they found a
>>   "pinmux-handle", so used in the following drivers in
>>   this patchserie:
>>
>>   drivers/net/ethernet/ti/davinci_emac
>>   drivers/i2c/busses/i2c-davinci.c
>>   drivers/mtd/nand/davinci_nand.c
>>
>> - post this board support with USB support, even though
>>   USB is only working with the 10 ms "workaround", posted here:
>>   http://comments.gmane.org/gmane.linux.usb.general/54505
>>   I see this issue also on the AM1808 TMDXEXP1808L evalboard.
>>
>> - MMC and USB are not using OF support yet, ideas how to port
>>   this are welcome. I need for USB and MMC board specific
>>   callbacks, how to solve this with OF support?
>>
>> Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
>> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
>> Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
>> Cc: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
>> Cc: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
>> Cc: Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>
>> Cc: Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>
>> Cc: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
>>
>> Heiko Schocher (7):
>>   ARM: davinci, intc: Add OF support for TI interrupt controller
>>   ARM: davinci: configure davinci aemif chipselects through OF
>>   ARM: davinci: mux: add OF support
>>   ARM: davinci: net: davinci_emac: add OF support
>>   ARM: davinci: i2c: add OF support
>>   ARM: mtd: nand: davinci: add OF support for davinci nand controller
>>   ARM: davinci: add support for the am1808 based enbw_cmc board
>>
>>  .../devicetree/bindings/arm/davinci/aemif.txt      |  119 ++++++
>>  .../bindings/arm/davinci/davinci_emac.txt          |   43 +++
>>  .../devicetree/bindings/arm/davinci/i2c.txt        |   33 ++
>>  .../devicetree/bindings/arm/davinci/intc.txt       |   27 ++
>>  .../devicetree/bindings/arm/davinci/mux.txt        |   40 ++
>>  .../devicetree/bindings/arm/davinci/nand.txt       |   74 ++++
>>  arch/arm/boot/dts/enbw_cmc.dts                     |  268 ++++++++++++++
>>  arch/arm/configs/enbw_cmc_defconfig                |  123 +++++++
>>  arch/arm/mach-davinci/Kconfig                      |    9 +
>>  arch/arm/mach-davinci/Makefile                     |    1 +
>>  arch/arm/mach-davinci/aemif.c                      |   86 +++++-
>>  arch/arm/mach-davinci/board-enbw-cmc.c             |  380 ++++++++++++++++++++
>>  arch/arm/mach-davinci/cp_intc.c                    |   87 ++++-
>>  arch/arm/mach-davinci/include/mach/aemif.h         |    1 +
>>  arch/arm/mach-davinci/include/mach/mux.h           |    2 +
>>  arch/arm/mach-davinci/include/mach/uncompress.h    |    1 +
>>  arch/arm/mach-davinci/mux.c                        |   73 ++++-
>>  drivers/i2c/busses/i2c-davinci.c                   |   37 ++
>>  drivers/mtd/nand/davinci_nand.c                    |   85 +++++-
>>  drivers/net/ethernet/ti/davinci_emac.c             |   94 +++++-
>>  20 files changed, 1569 insertions(+), 14 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/aemif.txt
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/i2c.txt
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/intc.txt
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/mux.txt
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/nand.txt
>>  create mode 100644 arch/arm/boot/dts/enbw_cmc.dts
>>  create mode 100644 arch/arm/configs/enbw_cmc_defconfig
>>  create mode 100644 arch/arm/mach-davinci/board-enbw-cmc.c
>>
> 
