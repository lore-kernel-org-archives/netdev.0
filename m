From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual
 emac case also
Date: Tue, 15 Apr 2014 15:46:00 +0200
Message-ID: <CAGm1_ktmygGNWqEvO=59ZVFbTprUHLuXAmSM3UXfVrShPJsz_g@mail.gmail.com>
References: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com> <20140409.145624.1000792872429500740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "N, Mugunthan V" <mugunthanvnm@ti.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:37204 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaDONqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 09:46:21 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so9632869pad.16
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 06:46:20 -0700 (PDT)
In-Reply-To: <20140409.145624.1000792872429500740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 9, 2014 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Wed, 9 Apr 2014 11:34:40 +0530
>
>> Dual EMAC works with VLAN segregation of the ports, so default vlan needs
>> to be added in dual EMAC case else default vlan will be tagged for all
>> egress packets and vlan unaware switches/servers will drop packets
>> from the EVM.

Hi Mugunthan,

though this patch fixes drop packets issue, it introduces another
issue. Just connect both interfaces to one switch and configure
different subnets. As soon as you get a broadcast you have an endless
loop and network communication is not possible at all. Before this
patch you could operate as if you had really two independent NICs.

Yegor
