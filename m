From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Wed, 11 Mar 2015 14:07:23 +0100
Message-ID: <20150311130723.GD2057@nanopsycho.orion>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
 <20150310211315.GF10838@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu Olivari <mathieu@codeaurora.org>, netdev@vger.kernel.org,
	linux@roeck-us.net, jogo@openwrt.org, f.fainelli@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34761 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbCKNH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 09:07:26 -0400
Received: by wiwl15 with SMTP id l15so36659322wiw.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 06:07:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150310211315.GF10838@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 10, 2015 at 10:13:15PM CET, andrew@lunn.ch wrote:
>> I was thinking about the MIB counters, maintained by the switch, on the CPU
>> port(s). 
>> 
>> On this picture:
>> 
>> +-----------+       +--------------------+
>> |           | RGMII |                    |
>> |       eth0+-------+ P0              P1 +------ 1000baseT MDI ("WAN")
>> |        wan|       |      7-port     P2 +------ 1000baseT MDI ("LAN1")
>> |   CPU     |       |      ethernet   P3 +------ 1000baseT MDI ("LAN2")
>> |           | RGMII |      switch     P4 +------ 1000baseT MDI ("LAN3")
>> |       eth1+-------+ P6   w/5 PHYs   P5 +------ 1000baseT MDI ("LAN4")
>> |        lan|       |                    |
>> +-----------+       +--------------------+
>>           |     MDIO   |
>>           \------------/
>> 
>> We can see MIB stats of P1/P2/P3/P4/P5 by using ethtool -S. But as CPU
>> ports don't have a net_device, there isn't a way to access MIB stats of
>> P0 & P6.
>
>Ah, sorry, i misunderstood you. As you say, the current DSA does not
>give you access to these counters. Apart from these counters, are
>there any other needs to have access to these ports? The core idea of
>hardware acceleration is that it should look like linux as normal.  P0
>and P6 are an internal detail, and you cannot actually use them. You
>cannot send packets, they are something special. So unless there is a
>good reason, we should not expose them.

I completely agree. Let's keep this internal ports scop within the
driver/dsa code.


>
>> If we have the eth0 <--> P0 and eth1 <--> P6 relationship information in dts,
>> we could use it to lookup which switch port is connected to this net_dev and
>> show the corresponding counters when running "ethtool -S ethN".
>
>But that is not what the user expects. They expect the statistic
>counters for ethN, not the switch port.
>
>	 Andrew
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
