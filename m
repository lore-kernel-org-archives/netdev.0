From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual
 emac case also
Date: Wed, 16 Apr 2014 11:27:38 +0530
Message-ID: <534E1BD2.5050809@ti.com>
References: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com> <20140409.145624.1000792872429500740.davem@davemloft.net> <CAGm1_ktmygGNWqEvO=59ZVFbTprUHLuXAmSM3UXfVrShPJsz_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yegor Yefremov <yegorslists@googlemail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:38299 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbaDPF5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2014 01:57:42 -0400
In-Reply-To: <CAGm1_ktmygGNWqEvO=59ZVFbTprUHLuXAmSM3UXfVrShPJsz_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 April 2014 07:16 PM, Yegor Yefremov wrote:
> On Wed, Apr 9, 2014 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
>> From: Mugunthan V N <mugunthanvnm@ti.com>
>> Date: Wed, 9 Apr 2014 11:34:40 +0530
>>
>>> Dual EMAC works with VLAN segregation of the ports, so default vlan needs
>>> to be added in dual EMAC case else default vlan will be tagged for all
>>> egress packets and vlan unaware switches/servers will drop packets
>>> from the EVM.
> Hi Mugunthan,
>
> though this patch fixes drop packets issue, it introduces another
> issue. Just connect both interfaces to one switch and configure
> different subnets. As soon as you get a broadcast you have an endless
> loop and network communication is not possible at all. Before this
> patch you could operate as if you had really two independent NICs.
>
>

This patch doesn't add any multicast or unicast entry in the ALE table,
so there is no possible way that a broadcast packet is switched within
the two external ports, and this patch removes the encapsulation of the
default vlan id which is used for internal packet switching inside CPSW
switch from host and any packet received from external port will be
tagged with port vlan so internal switching will happen with that port
vlan-id which will be only that physical port and host port. so the
scenario which you mentioned cannot happen theoretically untill you
enable bridge between the dual ethernet interface and connect both to
the same interface.

Regards
Mugunthan V N
