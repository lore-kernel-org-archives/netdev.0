From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH v6 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Thu, 24 May 2012 11:50:26 -0700
Message-ID: <4FBE82F2.6080100@gmail.com>
References: <1336007799-31016-1-git-send-email-ddaney.cavm@gmail.com> <CAOZdJXWVCu+aNxcQRkcSSDsWWxnn8B9X5Y6=8oVgFwJ9SZTTGQ@mail.gmail.com> <4FB6C728.3090507@gmail.com> <4FB6C886.3050105@freescale.com> <4FB6CBF1.40300@gmail.com> <4FBE7DD8.509@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Timur Tabi <b04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47384 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab2EXSu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 14:50:29 -0400
Received: by dady13 with SMTP id y13so128321dad.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 11:50:29 -0700 (PDT)
In-Reply-To: <4FBE7DD8.509@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2012 11:28 AM, Timur Tabi wrote:
> David Daney wrote:
>> Yes.  You may note in the DTS file I attached in the parent (sorry for
>> the fubar mime types), that there are two, almost identical, MDIO
>> masters.  smi0 has two directly attached PHYs.  smi1 goes to the mux,
>> and each child of the mux has four attached PHYs.
>
> I'm till have trouble understanding all this.  I'm just hacking things up
> in order to help me understand it, but it's a slow and painful process.
>
> This call in mdio_mux_init() is failing:
>
> 	parent_bus = of_mdio_find_bus(parent_bus_node);
>

Well, the MDIO bus must have an associated device tree node.

For my OCTEON code, the MDIO bus device is created as a result of the 
call to of_platform_bus_probe(), which takes care of filling in all the 
device tree nodes of the devices it finds and creates.

> It returns NULL.  Here is my MDIO node:
>
> 		fman0: fman@400000 {
> 			enet0: ethernet@e0000 {
> 				tbi-handle =<&tbi0>;
> 				phy-handle =<&phy0>;
> 				phy-connection-type = "sgmii";
> 			};
>
> 			mdio0: mdio@e1120 {
> 				gpios =<&gpio0 0 0
> 					&gpio0 1 0>;
>
> 				tbi0: tbi-phy@8 {
> 					reg =<0x8>;
> 					device_type = "tbi-phy";
> 				};
>
> 				phy0: ethernet-phy@1c {
> 					reg =<0x1c>;
> 				};
> 			};
> 		};
>
> What am I missing?

For starters, I do not see any compatible properties that would allow 
the proper drivers to be bound to anything.

Also I see no MDIO mux node there, so it is unclear why you are even 
asking these questions.

David Daney
