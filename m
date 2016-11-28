From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Mon, 28 Nov 2016 09:59:11 -0800
Message-ID: <025d5123-147f-346a-223d-b3a51e830cdd@gmail.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: Andrew Lunn <andrew@lunn.ch>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35718 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbcK1R7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:59:13 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so13735399pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:59:13 -0800 (PST)
In-Reply-To: <20161128141410.GF4379@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 06:14 AM, Andrew Lunn wrote:
> On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
>> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
>>
>> 3 types of PHY loopback are supported.
>> i.e. Near-End Loopback, Far-End Loopback and External Loopback.
> 
> Hi Allan
> 
> Is this integrated with ethtool --test? You only want the PHY to go
> into loopback mode when running ethtool --test external_lb or maybe
> ethtool --test offline.
> 
> What i think should happen is that this tunable sets the mode the PHY
> will go into when loopback is enabled. It does not however enable
> loopback. It is running ethtool --test which actually enables the
> loopback, probably by setting BMCR_LOOPBACK. Once the test is
> finished, the bit is cleared and the PHY goes back into normal
> operation.

Agreed with Andrew, there needs to be a tight coupling between the
existing ethtool test infrastructure, and how to perform PHY loopback
testing.

It makes sense for the PHY drivers to be able to implement specific
loopback/test mode, but we need to clarify how these get called from
ethtool --test for instance, and if the Ethernet MAC driver needs to do
something specific as well.
-- 
Florian
