From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Mon, 22 Aug 2016 15:44:35 +0200
Message-ID: <fe774740-7829-50df-a749-cec894bb7c74@neratec.com>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
 <AM5PR0401MB2561CB4CA30BC13EBFFAD43796160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <20160819163944.GF22939@lunn.ch>
 <AM5PR0401MB25618716FACFE3DA3A21D5F696160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <20160819214503.GC14068@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:46919 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755039AbcHVNpM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 09:45:12 -0400
In-Reply-To: <20160819214503.GC14068@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2016 11:45 PM, Andrew Lunn wrote:
>> Nice improvement.
> 
> Thanks
> 
>> But what's so special about 8?
> 
> When talking to Marvell Switch chips, there are two different headers
> which can be added. The DSA header is 4 bytes, and the EDSA header is
> 8 bytes. However, if there is already a VLAN header, when using EDSA,
> it will replace the VLAN header, so only need 4 additional bytes.
> There are some very old Marvell switches which add a 4 byte
> trailer. If you are talking to a Broadcom switch chip, it also has a 4
> byte header.
> 
>> I thought only 4 bytes were missing :)
> 
> So the requirement is probably not currently for the newer Marvell
> switch chips? But we should be looking forward and expect at some
> point somebody wants to use the newer chips. I've got a Freescale
> Vybrid board using the modern Marvell chips, but the FEC driver does
> not have a such a hard limit as this driver.
> 
> However, it does not seem as simple as that. A standard Ethernet frame
> should have a maximum size of 1522 when including a VLAN header. Yet
> the driver appears to be using 1536, which is this rounded up to
> multiples of 64. So there is already 14 spare bytes in there. So there
> must be something else going on here.
> 
>> At least 1536 is the default size of the MRBLR register, as specified
>> in the h/w ref manual.  Is there some recommended standard size
>> to accommodate most (if not all) headers, to refer to?
> 
> Not that i know of. These switch headers are proprietary.
> 
>     Andrew
> 
Hi,

it is a combination of
* (E)DSA header (+4/8 bytes)
* GMAC_FCB_LEN (8)
* FSL_GIANFAR_DEV_HAS_TIMER (causing priv->padding=8)
which sums up to a maximum frame size of 1538 and activates scatter-gather.

A v2 patch with better info is on its way.


Thanks,
Zefir
