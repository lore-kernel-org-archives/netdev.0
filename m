From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/2] net: ethoc: Fix early error paths
Date: Mon, 11 Jul 2016 10:15:05 -0700
Message-ID: <5783D419.5070702@gmail.com>
References: <1468256651-15896-1-git-send-email-f.fainelli@gmail.com>
 <1468256651-15896-2-git-send-email-f.fainelli@gmail.com>
 <20160711171143.GB8540@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jcmvbkbc@gmail.com,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35284 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbcGKRPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 13:15:08 -0400
Received: by mail-pa0-f52.google.com with SMTP id dx3so36571928pab.2
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 10:15:07 -0700 (PDT)
In-Reply-To: <20160711171143.GB8540@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 07/11/2016 10:11 AM, Andrew Lunn wrote:
> On Mon, Jul 11, 2016 at 10:04:10AM -0700, Florian Fainelli wrote:
>> In case any operation fails before we can successfully go the point
>> where we would register a MDIO bus, we would be going to an error label
>> which involves unregistering then freeing this yet to be created MDIO
>> bus. Update all error paths to go to label free which is the only one
>> valid until either the clock is enabled, or the MDIO bus is allocated
>> and registered. This fixes kernel panics such as this one:
>>
>> Fixes: a1702857724f ("net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.")
> 
> Hi Florian
> 
> Did you intend to paste a panic here?

I did, and then realized this was not so helpful since the NULL pointer
de-reference was fairly obvious, the driver is also not widely used
(AFAICT), I will respin the commit message to remove the last sentence,
thanks!
-- 
Florian
