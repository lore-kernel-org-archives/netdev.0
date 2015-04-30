From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 10:13:38 -0700
Message-ID: <554262C2.7060302@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-8-git-send-email-f.fainelli@gmail.com> <554232E9.5080104@roeck-us.net> <55425C53.6060509@gmail.com> <20150430170253.GD18874@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com,
	mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35006 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbD3RNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 13:13:50 -0400
Received: by pdbqd1 with SMTP id qd1so66623457pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 10:13:49 -0700 (PDT)
In-Reply-To: <20150430170253.GD18874@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 10:02, Andrew Lunn wrote:
>> The net advantage I see with this approach is that currently, with DSA,
>> you get to do the following:
>>
>> - register a "dsa" platform device
>> - force your CPU Ethernet MAC to hardcode link parameters, either via a
>> "fixed PHY" or via custom settings (ala mv643xx_eth)
>> - probing needs to occur in a *very* specific order: MDIO first,
>> Ethernet device second, DSA last
> 
> I'm not sure this is true. I'm pretty sure i've seen DSA return with
> -EPROBE_DEFER and try again later.

Right, I fixed that a little while ago, but that still prevents all the
scenarios described in my reply, in particular module unloading is
completely hairy, see this attempt:

http://permalink.gmane.org/gmane.linux.network/345803
-- 
Florian
