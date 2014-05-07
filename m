From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH] net: mdio: of_mdio: check for already registered phy
 before creating new instances
Date: Wed, 07 May 2014 18:01:51 +0200
Message-ID: <536A58EF.4070206@gmail.com>
References: <1399389711-32716-1-git-send-email-zonque@gmail.com> <CAGVrzcY+3xeDzMAe1683+ypF59eMN9oTss6LC_rLShuEpmC4NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:34215 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933028AbaEGQBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 12:01:54 -0400
Received: by mail-ee0-f43.google.com with SMTP id d17so894914eek.16
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 09:01:53 -0700 (PDT)
In-Reply-To: <CAGVrzcY+3xeDzMAe1683+ypF59eMN9oTss6LC_rLShuEpmC4NA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(+ Mugunthan V N)

Hi Florian,

On 05/07/2014 02:55 AM, Florian Fainelli wrote:
> 2014-05-06 8:21 GMT-07:00 Daniel Mack <zonque@gmail.com>:
>> In of_mdiobus_register_phy(), check if the phy with the given address is
>> already registered within the mii bus before calling phy_device_create()
>> or get_phy_device().
> 
> I am not exactly sure how you could be in that sort of situation.
> of_mdiobus_register() handles two different cases at the moment:
> 
> 1) PHY child nodes have a valid 'reg' property, and this property is
> used to register the PHY at the given address
> 2) if a PHY child node does not have a valid 'reg' property, which
> will trigger an auto-scan and then we iterate through all 32 addresses
> of the bus, we skip over PHYs that are already registered
> 
>>
>> This allows us to augment auto-probed phy devices with extra information
>> via DT. Without this patch, a second instance of the phydev is created
>> unnecessarily.
> 
> Which piece of code is doing the auto-probing in your case? One of the
> very first things that of_mdiobus_register() does is set the PHY mask
> to 0xffffffff to prevent the default PHY probing method to trigger,
> since we are using information from the Device Tree right after that.

Ah, ok. So what happens here is that of_mdiobus_register() sets the
phy_mask to ~0, but mdiobus_register() calls bus->reset(), which resets
the mask to ffffffef in my case. bus->reset is davinci_mdio_reset() in
my case.

Is the davinci mdio driver doing anything wrong by touching
bus->phy_mask? Another solution would be to split mdiobus_register() and
create a mdiobus_register_noscan() or something, and then call that from
of_mdiobus_register().


Thanks,
Daniel
