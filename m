From: Timur Tabi <b04825@freescale.com>
Subject: Re: [PATCH v6 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Thu, 24 May 2012 14:03:33 -0500
Message-ID: <4FBE8605.2020507@freescale.com>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com> <CAOZdJXWVCu+aNxcQRkcSSDsWWxnn8B9X5Y6=8oVgFwJ9SZTTGQ@mail.gmail.com> <4FB6C728.3090507@gmail.com> <4FB6C886.3050105@freescale.com> <4FB6CBF1.40300@gmail.com> <4FBE7DD8.509@freescale.com> <4FBE82F2.6080100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:15340
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751961Ab2EXTDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 15:03:43 -0400
In-Reply-To: <4FBE82F2.6080100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Daney wrote:

> Well, the MDIO bus must have an associated device tree node.
> 
> For my OCTEON code, the MDIO bus device is created as a result of the 
> call to of_platform_bus_probe(), which takes care of filling in all the 
> device tree nodes of the devices it finds and creates.

Ok, let me give you some background.  We actually already have MDIO muxing
code in-house, but it's different from yours.  So now I'm rewriting it to
use your design instead.

So our current code looks for "virtual MDIO nodes", and we call
mdiobus_alloc() and then of_mdiobus_register().  I think this is what I'm
missing now.

I just don't know what to do next.  Part of the problem is that I don't
have much experience with MDIO drivers.

>> It returns NULL.  Here is my MDIO node:
>>
>> 		fman0: fman@400000 {
>> 			enet0: ethernet@e0000 {
>> 				tbi-handle =<&tbi0>;
>> 				phy-handle =<&phy0>;
>> 				phy-connection-type = "sgmii";
>> 			};
>>
>> 			mdio0: mdio@e1120 {
>> 				gpios =<&gpio0 0 0
>> 					&gpio0 1 0>;
>>
>> 				tbi0: tbi-phy@8 {
>> 					reg =<0x8>;
>> 					device_type = "tbi-phy";
>> 				};
>>
>> 				phy0: ethernet-phy@1c {
>> 					reg =<0x1c>;
>> 				};
>> 			};
>> 		};
>>
>> What am I missing?
> 
> For starters, I do not see any compatible properties that would allow 
> the proper drivers to be bound to anything.

Ok, that makes sense.

> Also I see no MDIO mux node there, so it is unclear why you are even 
> asking these questions.

I only gave you part of the device tree.  Here's my mdio mux node:

	mdio-mux {
		compatible = "mdio-mux-gpio";
		gpios = <&gpio0 0 0>, <&gpio0 1 0>;
		mdio-parent-bus = <&mdio0>;
		#address-cells = <1>;
		#size-cells = <0>;

		mdio@2 {
			reg = <2>;
			#address-cells = <1>;
			#size-cells = <0>;

			phy21: ethernet-phy@1 {
				reg = <1>;
//				compatible = "marvell,88e1149r", "ethernet-phy-ieee802.3-c22";
				marvell,reg-init = <3 0x10 0 0x5777>,
					<3 0x11 0 0x00aa>,
					<3 0x12 0 0x4105>,
					<3 0x13 0 0x0a60>;
				interrupt-parent = <&gpio0>;
//				interrupts = <10 8>; /* Pin 10, active low */
			};
		};
	};
};




> 
> David Daney
> 


-- 
Timur Tabi
Linux kernel developer at Freescale
