From: John Crispin <john@phrozen.org>
Subject: Re: [RFC v3 1/3] NET: PHY: adds driver for Intel XWAY PHY
Date: Sat, 4 Jun 2016 16:55:30 +0200
Message-ID: <c695af6a-c3c3-752c-0f98-e43fe460d1f6@phrozen.org>
References: <1465040728-4904-1-git-send-email-hauke@hauke-m.de>
 <1465040728-4904-2-git-send-email-hauke@hauke-m.de>
 <0DAF21CFE1B20740AE23D6AF6E54843F1E503ECE@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "alexander.stein@systec-electronic.com"
	<alexander.stein@systec-electronic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"openwrt@kresin.me" <openwrt@kresin.me>,
	"Mehrtens, Hauke" <hauke.mehrtens@intel.com>,
	"daniel.schwierzeck@gmail.com" <daniel.schwierzeck@gmail.com>,
	"eckert.florian@googlemail.com" <eckert.florian@googlemail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: "Langer, Thomas" <thomas.langer@intel.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:39946 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbcFDOzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 10:55:35 -0400
In-Reply-To: <0DAF21CFE1B20740AE23D6AF6E54843F1E503ECE@IRSMSX101.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas
Hi Hauke

On 04/06/2016 16:43, Langer, Thomas wrote:
>> +		 /* there is an errata regarding irqs in this rev */
> And then this is comment is also now valid.
> What about a system with a single external phy connected,
> on a non-Lantiq/Intel SoC?
> 
> I think the feasibility of using interrupts is not related to the phy version,
> but indirectly by the version of the SoC it is integrated.
> 
> So maybe he use of interrupts (on these SoCs) should be controlled by devicetree or
> network driver, where the SoC type and version can be handled?
> 

IIRC the 2 irq lines are broken on xrx200 v1.1 SoC silicon. irqs were
unreliable and sometimes fired on the wrong phy or not at all. maybe
this was fixed on v1.2 silicon ? this is not related to the phy per-se
but the SoC silicon it is integrated into.

the PHY driver should be agnostic of the SoC having a functional IRQ
block i think. devictrees for v1.1 SoC silicon should simply not define
an IRQ inside the devicetree and rely on the phy polling done by the
mdio/phy layer.

	John
