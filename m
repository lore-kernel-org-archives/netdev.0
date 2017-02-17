From: Sriram V <vshrirama@gmail.com>
Subject: Re: Autoneg off in TI cpsw driver
Date: Fri, 17 Feb 2017 21:42:28 +0530
Message-ID: <CAH9_wROZsX1d3iEGUxs2yo8V9PArbUKnL1cyn_+NT+K2+c_t3Q@mail.gmail.com>
References: <CAH9_wRMwiZA6GxdwMbOZjs-t-hnMaCRB1RSQ6nGoLOUJ+PxzRw@mail.gmail.com>
 <20170216185729.GC6096@lunn.ch> <CAH9_wRMwFdMrbK9fBKwmBxpDkj2m8X3hqN9RcXbrpmf3muo_Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:35285 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934088AbdBQQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:12:30 -0500
Received: by mail-ua0-f181.google.com with SMTP id y9so32966103uae.2
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 08:12:30 -0800 (PST)
In-Reply-To: <CAH9_wRMwFdMrbK9fBKwmBxpDkj2m8X3hqN9RcXbrpmf3muo_Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

The following is the output of the ethtool and iplink. After turning
off the autoneg - The Plugin is not detected.
Let me know if this is a general behaviour or a bug in cpsw driver.


root@am437xevm:/ # ethtool  eth1
Settings for eth1:
Supported ports: [ TP AUI BNC MII FIBRE ]
Supported link modes:   10baseT/Half 10baseT/Full
                       100baseT/Half 100baseT/Full
Supported pause frame use: No
Supports auto-negotiation: Yes
Advertised link modes:  10baseT/Half 10baseT/Full
                       100baseT/Half 100baseT/Full
Advertised pause frame use: No
Advertised auto-negotiation: Yes
Speed: 100Mb/s
Duplex: Full
Port: MII
PHYAD: 1
Transceiver: external
Auto-negotiation: on
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000000 (0)

Link detected: yes
root@am437xevm:/ # ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT qlen 10
    link/can
3: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT qlen 1000
    link/ether c4:be:84:12:ae:0a brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT qlen 1000
    link/ether c4:be:84:34:af:0b brd ff:ff:ff:ff:ff:ff
root@am437xevm:/ #
root@am437xevm:/ #
root@am437xevm:/ # ethtool -s eth1 speed 10 duplex full autoneg off
root@am437xevm:/ # [  159.532534] libphy: 4a101000.mdio:01 - Link is Down

root@am437xevm:/ # ethtool eth1
Settings for eth1:
Supported ports: [ TP AUI BNC MII FIBRE ]
Supported link modes:   10baseT/Half 10baseT/Full
                       100baseT/Half 100baseT/Full
Supported pause frame use: No
Supports auto-negotiation: Yes
Advertised link modes:  10baseT/Full
Advertised pause frame use: No
Advertised auto-negotiation: No
Speed: 10Mb/s
Duplex: Full
Port: MII
PHYAD: 1
Transceiver: external
Auto-negotiation: off
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000000 (0)

Link detected: no
root@am437xevm:/ # ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT qlen 10
    link/can
3: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT qlen 1000
    link/ether c4:be:84:12:ae:0a brd ff:ff:ff:ff:ff:ff
4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT qlen 1000
    link/ether c4:be:84:34:af:0b brd ff:ff:ff:ff:ff:ff
root@am437xevm:/ #

On Fri, Feb 17, 2017 at 12:31 AM, Sriram V <vshrirama@gmail.com> wrote:
> Hi Andrew,
>
> 1. run ethtool -s eth1 speed 10 duplex full autoneg off
> 2. ethtool eth1 <-------------- shows link up
>
> 3. remove cable    <------- ethtool shows link down
> 4. plug it in.  <----------  ethtool Still shows link down
>
> I don't have the ip utility. I will cross compile it and get back to you.
>
> Thanks,
> Sriram
>
>
>
> On Fri, Feb 17, 2017 at 12:27 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> On Fri, Feb 17, 2017 at 12:01:32AM +0530, Sriram V wrote:
>>> Hi,
>>>
>>> I am using a Linux Kernel 4.1 Kernel. on AM437X with dual emac configuration.
>>>
>>> What i find is if i do the following the Link does not come up.
>>>
>>> 1. run ethtool -s eth1 speed 10 duplex full autoneg off
>>> 2. remove cable
>>> 3. plug it in.
>>>
>>> With the above sequence. The link does not come up. the plug in is not detected
>>
>> Hi Sriram
>>
>> There are a few different layers involved in this, we need to
>> determine which layer is unhappy.
>>
>> What does ethtool show?
>>
>> What does ip link show indicate?
>>
>>      Andrew
