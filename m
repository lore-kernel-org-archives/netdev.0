From: Leo Li <pku.leo@gmail.com>
Subject: Re: [v6, 3/5] dt: move guts devicetree doc out of powerpc directory
Date: Thu, 17 Mar 2016 16:33:35 -0500
Message-ID: <CADRPPNRPP0cxrJT13OR+dAWuw8m0mr0=VJLY+JyTO=QsB_vVUw@mail.gmail.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
	<1457518131-11339-4-git-send-email-yangbo.lu@nxp.com>
	<20160317170640.GB21009@rob-hp-laptop>
	<4107975.rId64mooHz@wuerfel>
	<CAL_JsqL8NkEQx2NoVHSUGYhtNsybCo-yfBCde+_OuMmfwbhYEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
	Ulf Hansson <ulf.hansson@linaro.org>,
	Zhao Qiang <qiang.zhao@freescale.com>, xiaobo.xie@nxp.com,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	linux-clk <linux-clk@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>, scott.wood@nxp.com,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Li Yang <leoyang.li@nxp.com>,
	Linux IOMMU <iommu@lists.linux-foundation.org>,
	Kumar Gala <galak@codeauro
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34197 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933278AbcCQVdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 17:33:37 -0400
In-Reply-To: <CAL_JsqL8NkEQx2NoVHSUGYhtNsybCo-yfBCde+_OuMmfwbhYEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 12:57 PM, Rob Herring <robh@kernel.org> wrote:
> On Thu, Mar 17, 2016 at 12:11 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Thursday 17 March 2016 12:06:40 Rob Herring wrote:
>>> > diff --git a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt b/Documentation/devicetree/bindings/soc/fsl/guts.txt
>>> > similarity index 91%
>>> > rename from Documentation/devicetree/bindings/powerpc/fsl/guts.txt
>>> > rename to Documentation/devicetree/bindings/soc/fsl/guts.txt
>>> > index b71b203..07adca9 100644
>>> > --- a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt
>>> > +++ b/Documentation/devicetree/bindings/soc/fsl/guts.txt
>>> > @@ -25,6 +25,9 @@ Recommended properties:
>>> >   - fsl,liodn-bits : Indicates the number of defined bits in the LIODN
>>> >     registers, for those SOCs that have a PAMU device.
>>> >
>>> > + - little-endian : Indicates that the global utilities block is little
>>> > +   endian. The default is big endian.
>>>
>>> The default is "the native endianness of the system".
>>
>> This may be what is currently documented, but not what we are doing
>> in practice, as there is no "native endianess" for either PowerPC or
>> ARM -- both allow running big-endian or little-endian kernels and the
>> device registers are fixed.
>
> Notice I said system, not architecture. The way the device registers
> are fixed is what I mean by native endianness.

I think sometimes it's also hard to define the native endianess of the
system too.  For whatever reason, we have hardware that having
big-endian registers on some on-chip devices but using little-endian
registers on other devices.  Even if all the devices on certain
hardware use registers of the same endianess, it is also hard for the
device driver to know what the native endianess really is.

>
> If the purpose of adding this property now is to support GUTS on the
> ARM SoCs, then I'd argue using this property is probably wrong. If the
> PPC systems are designed with BE device registers and ARM systems with
> LE, then this property is not needed.
>
>> I think the property here is fine.
>
> Unless you have studied the FSL ARM based SoCs, then there is not
> enough information here to tell.

Recent FSL ARM SoCs seems to have more weird endianess issue. :( The
same IP could have registers of different endianess on different ARM
SoCs.  That why we need to define the endianess explicitly in device
tree.

Regards,
Leo
