From: Matthias May <matthias.may@neratec.com>
Subject: [SIDE DISCUSSION] Re: [PATCH] phy state machine: failsafe leave
 invalid RUNNING state
Date: Wed, 4 Jan 2017 17:24:35 +0100
Message-ID: <ccab1089-4f3d-2557-c462-02276e2403da@neratec.com>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
 <6845805d-4dae-0a3a-c56c-6feb86f4b553@gmail.com>
 <82ffbb43-9345-c47d-596c-73c175ac7e7f@neratec.com>
 <16a741c1-7005-b1df-f2e6-afdbe9d086c8@gmail.com>
 <8521b51f-04f7-aeef-f862-bb150257cfa4@neratec.com>
 <20170104161615.GF5517@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:25345 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751958AbdADQcK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 11:32:10 -0500
In-Reply-To: <20170104161615.GF5517@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/17 17:16, Andrew Lunn wrote:
>> The setup is as follows:
>> mv88e6321:
>> * ports 0+1 connected to fibre-optics transceivers at fixed 100 Mbps
>> * port 4 is CPU port
>> * custom phy driver (replacement for marvell.ko) only populated with
>>   * .config_init to
>>     * set fixed speed for ports 0+1 (when in FO mode)
>>     * run genphy_config_init() for all other modes (here: CPU port)
>>   * .config_aneg=genphy_config_aneg, .read_status=genphy_read_status
> 
> Kicking off a side discussion:
> 
> Why do a custom PHY driver? What cannot you do with the current DSA
> code? I've got boards with two FO ports, and using fixed-phy is all i
> need to make them work on a 6352.
> 
>      Andrew
> 

We make two FO boards for 100Mbps and Gbit with different transceivers.
These different transceivers need each their own drive strength.
As Zefir wrote it's basically just a remap to the genphy functions with
some additional hardware specific register writes when the POR values
for FO configuration are detected on a port.

BR
Matthias
