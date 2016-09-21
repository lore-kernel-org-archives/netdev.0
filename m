From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 01/15] i40e: Introduce VF port representor/control netdevs
Date: Wed, 21 Sep 2016 07:22:21 +0300
Message-ID: <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com> <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com, Ilya Lesokhin <ilyal@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Rony Efraim <ronye@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34346 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbcIUEWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:22:22 -0400
Received: by mail-oi0-f65.google.com with SMTP id a62so2922853oib.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 21:22:21 -0700 (PDT)
In-Reply-To: <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 6:43 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>

> This patch enables creation of a VF Port representor/Control netdev
> associated with each VF. These netdevs can be used to control and configure
> VFs from PFs namespace. They enable exposing VF statistics, configuring
> link state, mtu, fdb/vlan entries etc.

What happens if someone does a xmit on the VF representor, does the
packet show up @ the VF?
and what happens of the VF xmits and there's no HW steering rule that
matches this, does
the frame show up @ the VF rep on the host?

In other words, can these VF reps serve for setting up host SW based
switching which you
can later offload (through TC, bridge, netfilter, etc)?

I am posing these questions because in downstream patch you are adding
devlink support
for set/get the e-switch mode and you declare the default mode to be switchdev.

When the switchdev mode was introduced in 4.8 these RX/TX
characteristics were defined
to be an essential (== requirement) part for a driver to support that mode.

Or

>     # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
>     # ip l show
>     297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
>     link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
>     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>     299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>     300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
