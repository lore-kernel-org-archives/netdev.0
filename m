From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCH 4/4] net: mvmdio: add getter and setter for PHY addresses
Date: Fri, 25 Jan 2013 20:58:51 +0100
Message-ID: <5102E3FB.7030808@openwrt.org>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org> <1359108409-4378-5-git-send-email-florian@openwrt.org> <20130125181629.GA7393@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	jason@lakedaemon.net, arnd@arndb.de, netdev@vger.kernel.org,
	gregory.clement@free-electrons.com, ian.molton@codethink.co.uk,
	linux-arm-kernel@lists.infradead.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:38140 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab3AYT66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 14:58:58 -0500
Received: by mail-bk0-f49.google.com with SMTP id w11so482745bku.8
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 11:58:56 -0800 (PST)
In-Reply-To: <20130125181629.GA7393@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/01/2013 19:16, Jason Gunthorpe a =E9crit :
> On Fri, Jan 25, 2013 at 11:06:49AM +0100, Florian Fainelli wrote:
>> This patch adds orion_mdio_{set,get}_phy_addr(.., port_number, phy_a=
ddr)
>> which is a feature available in this MDIO driver to monitor a partic=
ular
>> PHY address. This brings mvmdio one step closer to what is used in
>> mv643x_eth.
>
> This seems really strange.
>
> Are you sure this should be part of the MDIO driver? Based on my docs=
,
> this register is part of the ethernet controller HW, which
> autonomously reads from the phy via MDIO.

My reading of the datasheets for 88F628x and Armada 370 says that it=20
actually belongs to the MDIO part of the controller (it is just below=20
the SMI registers).

>
> It seems cleaner to set this register from the ethernet controller
> based on the phy it is using and keep the MDIO driver purely for MDIO
> bus access.
>
> It is acceptable to overlap the device address ranges, start the
> ethernet controller at 72000 and start the MDIO at 72004, the platfor=
m
> bus code automatically nests them.

Ok I did not think this would work, but I kind of prefer that too.
--
=46lorian
