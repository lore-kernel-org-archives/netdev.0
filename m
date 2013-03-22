From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/4 v3] mv643xx_eth: use mvmdio MDIO bus driver
Date: Fri, 22 Mar 2013 15:24:55 +0100
Message-ID: <514C69B7.8090106@openwrt.org>
References: <1363284515-9865-1-git-send-email-florian@openwrt.org> <1363959568-16976-1-git-send-email-florian@openwrt.org> <20130322141423.GJ13280@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>, Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130322141423.GJ13280@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/22/13 15:14, Jason Cooper a =C3=A9crit :
> On Fri, Mar 22, 2013 at 02:39:24PM +0100, Florian Fainelli wrote:
>> Hi all,
>>
>> This patch converts the mv643xx_eth driver to use the mvmdio MDIO bu=
s driver
>> instead of rolling its own implementation. As a result, all users of=
 this
>> mv643xx_eth driver are converted to register an "orion-mdio" platfor=
m_device.
>> The mvmdio driver is also updated to support an interrupt line which=
 reports
>> SMI error/completion, and to allow traditionnal platform device regi=
stration
>> instead of just device tree.
>>
>> David, I think it makes sense for you to merge all of this, since we=
 do
>> not want the architecture files to be desynchronized from the mv643x=
x_eth to
>> avoid runtime breakage. The potential for merge conflicts should be =
very small.
>>
>> Florian Fainelli (4):
>>    net: mvmdio: allow platform device style registration
>>    net: mvmdio: rename base register cookie from smireg to regs
>>    net: mvmdio: enhance driver to support SMI error/done interrupts
>>    mv643xx_eth: convert to use the Marvell Orion MDIO driver
>>
>>   .../devicetree/bindings/net/marvell-orion-mdio.txt |    3 +
>>   arch/arm/plat-orion/common.c                       |   54 +++---
>>   arch/powerpc/platforms/chrp/pegasos_eth.c          |   20 ++
>>   arch/powerpc/sysdev/mv64x60_dev.c                  |   16 +-
>>   drivers/net/ethernet/marvell/Kconfig               |    5 +-
>>   drivers/net/ethernet/marvell/Makefile              |    2 +-
>>   drivers/net/ethernet/marvell/mv643xx_eth.c         |  195 ++------=
------------
>>   drivers/net/ethernet/marvell/mvmdio.c              |  130 ++++++++=
++---
>>   include/linux/mv643xx_eth.h                        |    1 -
>>   9 files changed, 187 insertions(+), 239 deletions(-)
>
> Whole series applied on top of v3.9-rc3 and tested on dreamplug
> (kirkwood DT boot with legacy mv643xx_eth init)

Ok, thanks! Does that mean that you want these changes to go via your=20
tree? David initially applied my v2 of this patchset, and since it=20
thouches mostly ethernet driver stuff, I would rather make it go via hi=
s=20
tree if both of you agree.
--
=46lorian
