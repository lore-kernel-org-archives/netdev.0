From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Mon, 12 Sep 2016 10:27:40 -0400
Message-ID: <20160912142740.GM20632@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907203112.GA26445@lunn.ch>
 <20160907234306.GY33916@redhat.com>
 <20160908012413.GA12745@lunn.ch>
 <20160909180555.GE20632@redhat.com>
 <20160912024140.GA6264@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34864 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932235AbcILO1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:27:47 -0400
Received: by mail-wm0-f46.google.com with SMTP id a6so57051036wmc.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 07:27:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160912024140.GA6264@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 04:41:40AM +0200, Andrew Lunn wrote:
> > Actually breaking this up into easily digestable/mergeable chunks is going
> > to be kind of entertaining... Suggestions welcomed on that. First up is
> > obviously the core change, which touches just net/ethernet/eth.c,
> > net/core/dev.c, include/linux/netdevice.h and
> > include/uapi/linux/if_ether.h, and should let existing code continue to
> > Just Work(tm), though devices using ether_setup() that had no MTU range
> > checking (or one or the other missing) will wind up with new bounds.
> 
> Hi Jarod
> 
> Did you find any drivers which support jumbo packets, but don't have
> checks? These drivers, if there are any, need handling first, before
> this core change is made. Otherwise you introduce regressions.

Surprisingly, very few. There was dvb_net using eth_change_mtu and it's
max of 1500 while setting it's initial mtu to 4096, and I swear there was
at least one or two drivers that had no upper bounds checking at all that
I set max_mtu to IP_MAX_MTU (65535), but it's possible I missed something.

At the moment, things are roughly chopped up into:

1) core change
2) deprecate eth_change_mtu and remove in-kernel users
3) set m{in,ax}_mtu in ethernet drivers
4) set m{in,ax}_mtu in wireless drivers
5) set m{in,ax}_mtu in wan drivers
6) set m{in,ax}_mtu in usb ethernet drivers
7) set m{in,ax}_mtu in net infra
8) set m{in,ax}_mtu in virt drivers
9) set m{in,ax}_mtu in misc drivers

The ethernet drivers one is by far the largest, and was thinking I'd start
breaking that up next.

-- 
Jarod Wilson
jarod@redhat.com
