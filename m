From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v2 5/6] net: dsa: add missing calls in dsa_switch_destroy
Date: Thu, 29 Oct 2015 15:06:35 +0100
Message-ID: <563227EB.10708@baylibre.com>
References: <56321DCD.3070702@baylibre.com> <20151029140058.GS2307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37322 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757068AbbJ2OGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 10:06:42 -0400
Received: by wicfv8 with SMTP id fv8so44083093wic.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 07:06:41 -0700 (PDT)
In-Reply-To: <20151029140058.GS2307@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2015 03:00 PM, Andrew Lunn wrote:
> On Thu, Oct 29, 2015 at 02:23:25PM +0100, Neil Armstrong wrote:
>>
>> +		netif_carrier_off(ds->ports[port]);
>>  		unregister_netdev(ds->ports[port]);
>> +		phy_disconnect(p->phy);
>>  		free_netdev(ds->ports[port]);
>>  	}
> 
> Once you make it actually compile....
> 
> I'm not sure this is safe. The loop above this one has just destroyed
> some phys, and now you are potentially disconnecting a phy you just
> destroyed, causing it to be accessed?
> 
> I would suggest you first fix the ordering in dsa_switch_destroy()
> and then add the missing netif_carrier_off() and phy_disconnect().
> 
> Thanks
> 	Andrew
> 

Yes, you are right, I will submit a cleaned up version.
I forgot the fixed phy case actually.

Thanks,
Neil
