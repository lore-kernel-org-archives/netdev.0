From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: Order of interfaces in output of ip link
Date: Tue, 2 Sep 2014 18:04:25 +0300
Message-ID: <CAMw6YJJg4zkmTTMRMpJ06UrK+SFnYCjBn8TpMO4rJ5L4-ib_2A@mail.gmail.com>
References: <19313218.dxlnVqzEMb@hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Ovidiu Mara <ovidiu.mara@epfl.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35423 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbaIBPE0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 11:04:26 -0400
Received: by mail-qg0-f47.google.com with SMTP id z60so6708085qgd.34
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 08:04:25 -0700 (PDT)
In-Reply-To: <19313218.dxlnVqzEMb@hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Seems ip tool gets interfaces list via rtnetlink from index hash list
but /proc/net/dev gets them from dev name hash list,
hence the different order.

Regards,

On Tue, Sep 2, 2014 at 5:27 PM, Ovidiu Mara <ovidiu.mara@epfl.ch> wrote:
> Hi everyone,
>
> The ip command shows the interfaces on this machine in an unnatural order (eth0 followed by eth2 then eth1).
>
> For example:
>
> ip -o link
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default \    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a4 brd ff:ff:ff:ff:ff:ff
> 3: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d8 brd ff:ff:ff:ff:ff:ff
> 4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a5 brd ff:ff:ff:ff:ff:ff
> 5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d9 brd ff:ff:ff:ff:ff:ff
> 6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:da brd ff:ff:ff:ff:ff:ff
> 7: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:db brd ff:ff:ff:ff:ff:ff
> 8: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000\    link/ether a0:36:9f:26:b3:10 brd ff:ff:ff:ff:ff:ff
> 9: eth7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether a0:36:9f:26:b3:12 brd ff:ff:ff:ff:ff:ff
>
> eth0 and eth1 are two ports on the same network card, so I would expect them to be shown together, as they are numbered. According to the documentation I found here ( http://www.policyrouting.org/iproute2.doc.html#ss9.1.1 ): "The number followed by a colon is the interface index or ifindex. This number uniquely identifies the interface. If you look at the output from cat /proc/net/dev you will see that the network devices are listed in the same order as the numbering you see here."
>
> However in /proc/net/dev they are shown in the natural order:
>
> cat /proc/net/dev
> Inter-|   Receive                                                |  Transmit
>  face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
>   eth0: 1000705102 6535806    0 8946    0     0          0   2861813  5252988   39289    0    0    0     0       0          0
>   eth1:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
>   eth2: 104506836  257406    0    0    0     0          0         0      648       8    0    0    0     0       0          0
>   eth3: 104506430  257405    0    0    0     0          0         0      648       8    0    0    0     0       0          0
>   eth4: 104506430  257405    0    0    0     0          0         0      648       8    0    0    0     0       0          0
>   eth5: 104505618  257403    0    0    0     0          0         0      648       8    0    0    0     0       0          0
>   eth6:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
>   eth7: 396628856508 364243051    0    0    0     0          0         0 398063721522 365214422    0    0    0     0       0          0
>     lo:     178       2    0    0    0     0          0         0      178       2    0    0    0     0       0          0
>
> I'm using iproute2-3.11.0.
>
> Could you please tell me if there is any workaround for this?
>
> Thanks,
> Ovidiu
>
> PS Please CC me in replies.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
