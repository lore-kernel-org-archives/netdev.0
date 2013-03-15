From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/4] mv643xx_eth: use mvmdio MDIO bus driver
Date: Fri, 15 Mar 2013 13:53:10 +0100
Message-ID: <514319B6.7030307@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org> <1363284515-9865-1-git-send-email-florian@openwrt.org> <20130315.085321.1047694772636447477.davem@davemloft.net> <20130315.085510.974056254781971889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	rob@landley.net, jason@lakedaemon.net, andrew@lunn.ch,
	linux@arm.linux.org.uk, benh@kernel.crashing.org, paulus@samba.org,
	buytenh@wantstofly.org, thomas.petazzoni@free-electrons.com,
	gregkh@linuxfoundation.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130315.085510.974056254781971889.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/15/13 13:55, David Miller a =C3=A9crit :
> From: David Miller <davem@davemloft.net>
> Date: Fri, 15 Mar 2013 08:53:21 -0400 (EDT)
>
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Thu, 14 Mar 2013 19:08:31 +0100
>>
>>> This patch converts the mv643xx_eth driver to use the mvmdio MDIO b=
us driver
>>> instead of rolling its own implementation. As a result, all users o=
f this
>>> mv643xx_eth driver are converted to register an "orion-mdio" platfo=
rm_device.
>>> The mvmdio driver is also updated to support an interrupt line whic=
h reports
>>> SMI error/completion, and to allow traditionnal platform device reg=
istration
>>> instead of just device tree.
>>>
>>> David, I think it makes sense for you to merge all of this, since w=
e do
>>> not want the architecture files to be desynchronized from the mv643=
xx_eth to
>>> avoid runtime breakage. The potential for merge conflicts should be=
 very small.
>>
>> All applied to net-next, thanks.
>
> Actually, reverted.  Please send me code which actually compiles:
>
> drivers/net/ethernet/marvell/mvmdio.c: In function =E2=80=98orion_mdi=
o_wait_ready=E2=80=99:
> drivers/net/ethernet/marvell/mvmdio.c:70:28: error: =E2=80=98NO_IRQ=E2=
=80=99 undeclared (first use in this function)
> drivers/net/ethernet/marvell/mvmdio.c:70:28: note: each undeclared id=
entifier is reported only once for each function it appears in
> drivers/net/ethernet/marvell/mvmdio.c: In function =E2=80=98orion_mdi=
o_probe=E2=80=99:
> drivers/net/ethernet/marvell/mvmdio.c:242:24: error: =E2=80=98NO_IRQ=E2=
=80=99 undeclared (first use in this function)
> make[4]: *** [drivers/net/ethernet/marvell/mvmdio.o] Error 1
>
> And don't use Kconfig dependencies to work around this, fix it proper=
ly.

Is there any platform out there for which we do not have a NO_IRQ=20
definition by now? If so, what is it?
--
=46lorian
