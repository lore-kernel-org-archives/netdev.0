From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Set a "dsa" device_type
Date: Thu, 24 Sep 2015 17:28:58 -0700
Message-ID: <5604954A.7090409@gmail.com>
References: <1443057598-25729-1-git-send-email-f.fainelli@gmail.com> <20150924223748.GA6064@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33551 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbbIYA3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:29:07 -0400
Received: by pacex6 with SMTP id ex6so87573091pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:29:07 -0700 (PDT)
In-Reply-To: <20150924223748.GA6064@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/15 15:37, Vivien Didelot wrote:
> Hi Florian,
> 
> On Sep. Wednesday 23 (39) 06:19 PM, Florian Fainelli wrote:
>> Provide a device_type information for slave network devices created by
>> DSA, this is useful for user-space application to easily locate/search
>> for devices of a specific kind.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Noob question, how is that used from user-space?

This changes the 'uevent' attribute, before, it would look like this:

cat /sys/class/net/gphy/uevent
OF_NAME=port
OF_FULLNAME=/rdb/switch_top@f0b00000/ethernet_switch@0/switch@0/port@0
OF_COMPATIBLE_N=0
OF_ALIAS_0=switch_port0
INTERFACE=gphy
IFINDEX=3
#

With that change it looks like this:

# cat /sys/class/net/gphy/uevent
DEVTYPE=dsa
OF_NAME=port
OF_FULLNAME=/rdb/switch_top@f0b00000/ethernet_switch@0/switch@0/port@0
OF_COMPATIBLE_N=0
OF_ALIAS_0=switch_port0
INTERFACE=gphy
IFINDEX=3

VLAN does a similar thing:

DEVTYPE=vlan
INTERFACE=eth0.2
IFINDEX=14

> 
> Also, don't you think that this "dsa" device type might be conflicting
> with eventually exposed DSA ports? Or will they all get the same type?

Well, as of today these ports are not exposed, it is unclear to me
whether they would be real network devices (with an actual struct device
backing them), and we may want to dedicate a specific DEVTYPE like
"dsa-pseudo-port" or something like that, specifically for these devices.

Hope this clarifies the intent and usefulness of the patch.
-- 
Florian
