From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Mon, 26 Aug 2013 12:15:24 +0530
Message-ID: <521AF984.7090405@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com> <52178E20.5040404@gmail.com> <52179448.1020906@ti.com> <5217974B.5090503@ti.com> <521799A3.7080706@ti.com> <52179AD6.8090406@gmail.com> <52179BDA.50603@ti.com> <52179E44.5030202@ti.com> <5217A59E.4090700@ti.com> <5217AA15.7010907@ti.com> <5217BDFA.5040904@ti.com> <521AEECF.8060606@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>,
	Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>,
	<bcousson@baylibre.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:53295 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755892Ab3HZGt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 02:49:59 -0400
In-Reply-To: <521AEECF.8060606@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 August 2013 11:29 AM, Mugunthan V N wrote:
> On Saturday 24 August 2013 01:24 AM, Santosh Shilimkar wrote:
>> On Friday 23 August 2013 02:29 PM, Mugunthan V N wrote:
>>> On Friday 23 August 2013 11:40 PM, Santosh Shilimkar wrote:
>>>> On Friday 23 August 2013 01:39 PM, Sekhar Nori wrote:
>>>>> On 8/23/2013 10:58 PM, Santosh Shilimkar wrote:
>>>>>> On Friday 23 August 2013 01:24 PM, Daniel Mack wrote:
>>>>>>> On 23.08.2013 19:19, Santosh Shilimkar wrote:
>>>>>>>> On Friday 23 August 2013 01:09 PM, Sekhar Nori wrote:
>>>>>>>>> On 8/23/2013 10:26 PM, Santosh Shilimkar wrote:
>>>>>>>>>> So just stick the IP version or call it cpsw-v1... cpsw-v2 e=
tc.
>>>>>>>>> If this could be handled using IP version then the right way =
would be to
>>>>>>>>> just read the IP version from hardware and use it. No need of=
 DT property.
>>>>>>>>>
>>>>>>>> Thats fine as well but I thought the patch needed additional p=
roperties like
>>>>>>>> CM reg-address come from DT and hence the separate compatible.=
 If you can
>>>>>>>> manage without that, thats even better.
>>>>>>> We can't, that's the whole point :)
>>>>>>>
>>>>>> I saw that from the patch :)
>>>>>>
>>>>>>> Well, theoretically, we could for now, but that's not a clean s=
olution.
>>>>>>> Again: the problem here is that the control port is separated f=
rom the
>>>>>>> cpsw core, and so we have to implement something specific for t=
he AM3352
>>>>>>> SoC. I know that's a violation of clean and generic driver idea=
s, but
>>>>>>> there's no way we can assume that every cpsw v2 ip block has a =
control
>>>>>>> port that is compatible to the one found on am335x chips.
>>>>>>>
>>>>>> But there is a possibility that other SOC will just use the same
>>>>>> control module approach. So using a revision IP is just fine. BT=
W,
>>>>> But this is misleading because it makes appear like the same comp=
atible
>>>>> can be used on on another SoC like DRA7 which probably has the sa=
me
>>>>> version of IP but a different control module implementation, when=
 in
>>>>> practice it cannot.
>>>>>
>>>>> The fact is we are doing something SoC specific in the driver and=
 we
>>>>> cannot hide that behind IP versions. If really in practice there =
comes
>>>>> another SoC with the same control module definition then it can a=
lways
>>>>> use ti,am3352-cpsw compatible as well. The compatible name does n=
ot
>>>>> preclude its usage.
>>>>>
>>>> My point was the CPSW needs a feature which is implemented using
>>>> control module rather than within the IP itself. Its an implementa=
tion
>>>> detail. As such the additional feature makes sense for that IP. O.=
w
>>>> there was no need to do any monkeying with control module.
>>>>
>>>> E.g
>>>> MMC card detect is a basic functionality, implemented by various t=
ypes
>>>> like control module, PMIC or MMC IP itself. As such the driver nee=
d
>>>> that support and all the implementation details needs to still han=
dled
>>>> to make that part work.
>>>>
>>>>
>>> CPSW core as such understands only GMII/MII signals, there is an
>>> additional module which converts GMII/MII signals to RGMII/RMII sig=
nals
>>> respectively which is called as CPRGMII/CPRMII as specified in the
>>> AM335x TRM in Figure 14-1. Ethernet Switch Integration.
>>>
>>> So to control this sub-module, the control register is used and thi=
s has
>>> to be configured according to the EVM design like what mode of phy =
is
>>> connected. CPRGMII and CPRMII is no way related to CPSW core.
>>>
>> Ok then why are you polluting cpsw driver with that code which
>> not realted to CPSW as you said above. You are contradicting what
>> you said by supporting the SOC usage in the core CPSW driver.
> This patch series is not from me and because of the reason I mentione=
d
> about control module driver, so that cpsw driver can make use control
> module apis to select phy mode and control module driver takes care o=
f
> SoC specific register offsets and definitions, but now it is not
> possible as it is not acceptable in mainline. So other way is to keep
> these in driver itself as it is done in this patch series with SoC
> compatibilities.

What is done in this patch is _not_ "SoC compatibilities". SoC
compatibility would be what was done in v1 of this patch ie, explicit
check for

	of_machine_is_compatible("ti,am33xx")

"ti,am3352-cpsw" says "CPSW as implemented on AM3352". This is not the
same as checking if SoC is AM3352.

The example quoted on ePAPR spec for a compatible string is:

	compatible =3D =E2=80=9Cfsl,mpc8641-uart=E2=80=9D, =E2=80=9Cns16550";

MPC8641 is freescale PowerPC based SoC[1]. This shows that it is not
unnatural to use SoC names in compatibles for IPs. That, or the ePAPR
specification needs to be updated to show the right example of how a
compatible could be defined. Until then I see no reason of changing wha=
t
is implemented in this patch.

In short, even if there was no control module handling in the driver,
using "ti,am3352-cpsw" would be just fine.

I have also CCed the DT maintainers for their opinion. They should have
been explicitly CCed anyway.

Thanks,
Sekhar

[1] http://www.freescale.com/files/32bit/doc/data_sheet/MPC8641DEC.pdf
