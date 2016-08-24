From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH] dt: net: enhance DWC EQoS binding to support Tegra186
Date: Wed, 24 Aug 2016 14:43:29 -0600
Message-ID: <80149ae2-2b4a-9b8a-b261-e37ebdcafb57@wwwdotorg.org>
References: <20160823204757.17998-1-swarren@wwwdotorg.org>
 <259bfaa8-6dcb-eafc-da9c-c16ec7d39d24@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lars Persson <larper@axis.com>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, Stephen Warren <swarren@nvidia.com>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:37006 "EHLO
        avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755601AbcHXUnd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 16:43:33 -0400
In-Reply-To: <259bfaa8-6dcb-eafc-da9c-c16ec7d39d24@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2016 02:10 AM, Lars Persson wrote:
> On 08/23/2016 10:47 PM, Stephen Warren wrote:
>> The Synopsys DWC EQoS is a configurable IP block which supports multiple
>> options for bus type, clocking and reset structure, and feature list.
>> Extend the DT binding to define a "compatible value" for the
>> configuration
>> contained in NVIDIA's Tegra186 SoC, and define some new properties and
>> list property entries required by that configuration.

>> diff --git
>> a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>> b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt

>>  Optional properties:

>> +- phy-reset-gpios: Phandle and specifier for any GPIO used to reset
>> the PHY.
>> +  See ../gpio/gpio.txt.
>
> IMHO the phy reset gpio belongs in the binding for the PHY. I notice
> some other ethernet drivers have this, but the PHY should be managed
> entirely through the phylib and any special handling for reset can be
> hidden in phy specific drivers.

I can see that argument; this GPIO certainly does control the PHY so 
seems part of it. However, presumably this GPIO must be manipulated 
before being able to communicate with the PHY at all, and hence 
instantiate any driver that might control the PHY. As such, this seems 
more like a property of the MDIO bus than the PHY itself, even if it 
electrically is part of the PHY. Also, 
Documentation/devicetree/bindings/net/phy.txt doesn't contain any 
phy-reset-gpios property or similar, so we'd have to add that if we 
wanted to rely upon it.

For now I'll post V2 without changing this, but I can always post V3 if 
needed.
