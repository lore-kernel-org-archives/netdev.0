From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: _DSD standardization note (WAS: Re: [PATCH 2/2] net, thunder,
 bgx: Add support for ACPI binding.)
Date: Tue, 8 Sep 2015 10:17:04 -0700
Message-ID: <55EF1810.40300@caviumnetworks.com>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>	<1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com>	<20150807140106.GE7646@leverpostej>	<55C4ECC6.7050908@caviumnetworks.com>	<20150807175127.GB12013@leverpostej>	<CAJZ5v0gc=bo3ayO7aWq19Hh_205YC52wqXGbbM5vxR1atXm+oA@mail.gmail.com>	<55C5494D.5010903@caviumnetworks.com> <CAJZ5v0iNqRsrpwzWY5o97R1S+Dr-CzRPg3Cymt1q4v5gvABCQA@mail.gmail.com> <55EB49E5.5040206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rafael@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	David Daney <ddaney.cavm@gmail.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"rob.herring@linaro.org" <rob.herring@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	David Daney <david.daney@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Robert Richter <rrichter@cavium.com>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Jon Masters <jcm@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0056.outbound.protection.outlook.com ([65.55.169.56]:58640
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752071AbbIHRRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 13:17:14 -0400
In-Reply-To: <55EB49E5.5040206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2015 01:00 PM, Jon Masters wrote:
> Following up on this thread after finally seeing it...figured I would
> send something just for the archive mainly (we discussed this in person
> recently at a few different events and I think are aligned already).
>
> On 08/07/2015 08:28 PM, Rafael J. Wysocki wrote:
>> Hi David,
>>
>> On Sat, Aug 8, 2015 at 2:11 AM, David Daney <ddaney@caviumnetworks.com> wrote:
>>> On 08/07/2015 05:05 PM, Rafael J. Wysocki wrote:
>>
>> [cut]
>>
>>>>
>>>> It is actually useful to people as far as I can say.
>>>>
>>>> Also, if somebody is going to use properties with ACPI, why whould
>>>> they use a different set of properties with DT?
>
> Generally speaking, if there's a net new thing to handle, there is of
> course no particular problem with using DT as an inspiration, but we
> need to be conscious of the fact that Linux isn't the only Operating
> System that may need to support these bindings, so the correct thing (as
> stated by many of you, and below, and in person also recently - so we
> are aligned) is to get this (the MAC address binding for _DSD in ACPI)
> standardized properly through UEFI where everyone who has a vest OS
> interest beyond Linux can also have their own involvement as well. As
> discussed, that doesn't make it part of ACPI6.0, just a binding.
>
> FWIW I made a decision on the Red Hat end that in our guidelines to
> partners for ARM RHEL(SA - Server for ARM) builds we would not generally
> endorse any use of _DSD, with the exception of the MAC address binding
> being discussed here. In that case, I realized I had not been fully
> prescriptive enough with the vendors building early hw in that I should
> have realized this would happen and have required that they do this the
> right way. MAC IP should be more sophisticated such that it can handle
> being reset even after the firmware has loaded its MAC address(es).
> Platform flash storage separate from UEFI variable storage (which is
> being abused to contain too much now that DXE drivers then load into the
> ACPI tables prior to exiting Boot Services, etc.) should contain the
> actual MAC address(es), as it is done on other arches, and it should not
> be necessary to communicate this via ACPI tables to begin with (that's a
> cost saving embedded concept that should not happen on server systems in
> the general case). I have already had several unannounced future designs
> adjusted in light of this _DSD usage.
>
> In the case of providing MAC address information (only) by _DSD, I
> connected the initial ARMv8 SoC silicon vendors who needed to use such a
> hack to ensure they were using the same properties, and will followup
> off list to ensure Cavium are looped into that. But, we do need to get
> the _DSD property for MAC address provision standardized through UEFI
> properly as an official binding rather than just a link on the website,
> and then we need to be extremely careful not to grow any further
> dependence upon _DSD elsewhere. Generally, if you're using that approach
> on a server system (other than for this MAC case), your firmware or
> design (or both) need to be modified to not use _DSD.

I think we need to be cognizant of the fact that ARMv8 SoCs do contain, 
and in the future will still contain, many different hardware bus 
interface devices.  These include I2C, MDIO, GPIO, xMII (x in {,SG,RGM, 
etc} network MAC interfaces).  In the context of network interfaces 
these are often used in conjunction with stand-alone PHY devices.

A network driver on such a system must know several things that cannot 
be probed, and thus must be communicated by the firmware:

  - PHY type/model-number.

  - PHY management channel (MDIO/I2C + management bus address)

  - PHY interrupt connection, if any, (Often a GPIO pin).

  - SFP eeprom location (Which I2C bus is it on).

On x86 systems, all those things were placed on a PCI NIC, and the 
configuration could be identified in a stand alone manner by the NIC 
driver, so everything was simple.

For SoC based systems, I don't see a better alternative than to expose 
the topology via firmware tables.  In the case of OF device-tree, this 
is done in a standard manner with "phy-handle" and "interrupts" 
properties utilizing phandle links to traverse branches of the device tree.

I am not an ACPI guru, so I don't know for certain the best way to 
express this in ACPI, but it seems like _DSD may have to be involved.

David Daney
