From: Greg <gvrose8192@gmail.com>
Subject: Re: ip link SR-IOV VF MAC address disparity
Date: Wed, 25 Jan 2017 07:49:47 -0800
Message-ID: <1485359387.29083.3.camel@gmail.com>
References: <CA+mNUtCquJF9TxTRs9GF7XdBhxDUS_LwWA8M5QZbeXoRGNrZ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Kenigsberg <danken@redhat.com>,
        Edward Haas <ehaas@redhat.com>
To: Leon Goldberg <lgoldber@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35233 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751487AbdAYPtt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:49:49 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so14640027pfa.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 07:49:49 -0800 (PST)
In-Reply-To: <CA+mNUtCquJF9TxTRs9GF7XdBhxDUS_LwWA8M5QZbeXoRGNrZ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 15:34 +0200, Leon Goldberg wrote:
> Hey,
> 
> Using ip link to retrieve the MAC addresses of some SR-IOV virtual
> functions, I'm receiving mixed results:
> 
> [root@nari05 sys]# ip link
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: enp2s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq
> master ovirtmgmt state UP mode DEFAULT qlen 1000
>     link/ether 78:e7:d1:e4:9b:64 brd ff:ff:ff:ff:ff:ff
> 3: enp2s0f1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq master test1
> state DOWN mode DEFAULT qlen 1000
>     link/ether 78:e7:d1:e4:9b:65 brd ff:ff:ff:ff:ff:ff
>     vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>     vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>     vf 2 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>     vf 3 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
>     vf 4 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
> 4: ovirtmgmt: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP mode DEFAULT
>     link/ether 78:e7:d1:e4:9b:64 brd ff:ff:ff:ff:ff:ff
> 5: test1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
> state DOWN mode DEFAULT
>     link/ether 78:e7:d1:e4:9b:65 brd ff:ff:ff:ff:ff:ff
> 11: ;vdsmdummy;: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT
>     link/ether 5e:b4:ac:5c:b9:a1 brd ff:ff:ff:ff:ff:ff
> 37: enp2s16f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT qlen 1000
>     link/ether 00:00:00:00:00:02 brd ff:ff:ff:ff:ff:ff
> 38: enp2s16f3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT qlen 1000
>     link/ether d6:ee:45:57:c0:39 brd ff:ff:ff:ff:ff:ff
> 39: enp2s16f5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT qlen 1000
>     link/ether 4a:2c:25:42:97:4a brd ff:ff:ff:ff:ff:ff
> 40: enp2s16f7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT qlen 1000
>     link/ether c2:fe:2f:5e:f5:e8 brd ff:ff:ff:ff:ff:ff
> 41: enp2s17f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT qlen 1000
>     link/ether e6:31:a9:59:5f:ad brd ff:ff:ff:ff:ff:ff
> 
> enp2s0f1 is the physical function; enp2s1f* are the interfaces to the
> virtual functions.
> 
> Essentially, I have 2 questions:
> 1) What is the difference between the entries under the physical
> function and the interfaces?
> 2) How should I retrieve the correct MAC addresses? I'm aware of
> /sys/.../<vf>/net/address, but I am now not sure it is the correct
> source.

If you haven't used ip link commands to set the VF device MAC addresses
then the devices will create their own as they register their net device
entries.  In that case you'll see the VF MAC addresses as all 00's
because you haven't set them.

Best known methods call for using the ip link command to set the MAC
addresses for the VF devices rather than letting them set their own
temporary LAA type MAC addresses.

- Greg

> 
> Thanks,
> Leon
