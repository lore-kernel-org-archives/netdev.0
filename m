From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 08:00:17 -0700
Message-ID: <451A9201.6000600@intel.com>
References: <20060926145113.7a6791c8@freekitty>	<4519A1D6.1050802@pobox.com> <20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7035 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S932462AbWI0PCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:02:34 -0400
To: David Acker <dacker@roinet.com>
In-Reply-To: <451A7603.1030204@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
> Stephen Hemminger wrote:
>> On Tue, 26 Sep 2006 17:55:34 -0400
>> Jeff Garzik <jgarzik@pobox.com> wrote:
>>
>>> Stephen Hemminger wrote:
>>>> The mii-tool utility seems to be abandoned and unmaintained?
>>>>
>>>> Here is a version that does standard 1000baseT support.
>>>>     http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
>>> Not really.  I would rather leave it as-is, and deprecate it in favor 
>>> of ethtool.
>>>
>>
>> It does make a handy debug tool when driver isn't doing MII correctly.
>>
> 
> mii-tool supports some things that ethtool does not.  mii-tool -A lets 
> you set the advertised speeds and can include a list of speeds.  The 
> closest ethtool seems to have is ethtool -s but that seems to just set 
> the advertised speed to a single value only.

We sent a patch for this to Jeff recently that allows setting of 'arbitrary' 
speeds. Unfortunately the interface is rather crude but it works (for e1000, 
and possibly all other nics) to set any combination of advertised speeds.

e.g. `ethtool -s eth0 advertise 0x0f` advertises all non-gigabit speeds

I haven't seen the patch merged yet upstream though.

Cheers,

Auke

> 
> We have instances where we want to limit the link of the ethernet port 
> to no higher then 10 Mbps full duplex but also advertise support for 
> half duplex.
> 
> With mii-tool we can do the command below and work with a half duplex 
> hub and a full duplex switch.
> mii-tool -A 10baseT-FD,10baseT-HD eth0
> 
> Meanwhile if I use ethtool like the command below I will not work with a 
> half duplex only hub.
> ethtool -s eth0 speed 10 duplex full autoneg on
> 
> Perhaps the "speed" part of ethtool -s should take a list of speeds like 
> mii-tool does.
> 
> -Ack
