From: Leon Goldberg <lgoldber@redhat.com>
Subject: ip link SR-IOV VF MAC address disparity
Date: Wed, 25 Jan 2017 15:34:48 +0200
Message-ID: <CA+mNUtCquJF9TxTRs9GF7XdBhxDUS_LwWA8M5QZbeXoRGNrZ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Kenigsberg <danken@redhat.com>, Edward Haas <ehaas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33665 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdAYNev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 08:34:51 -0500
Received: by mail-lf0-f46.google.com with SMTP id x1so42080169lff.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 05:34:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

Using ip link to retrieve the MAC addresses of some SR-IOV virtual
functions, I'm receiving mixed results:

[root@nari05 sys]# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp2s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq
master ovirtmgmt state UP mode DEFAULT qlen 1000
    link/ether 78:e7:d1:e4:9b:64 brd ff:ff:ff:ff:ff:ff
3: enp2s0f1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq master test1
state DOWN mode DEFAULT qlen 1000
    link/ether 78:e7:d1:e4:9b:65 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 2 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 3 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
    vf 4 MAC 00:00:00:00:00:00, spoof checking on, link-state auto
4: ovirtmgmt: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
state UP mode DEFAULT
    link/ether 78:e7:d1:e4:9b:64 brd ff:ff:ff:ff:ff:ff
5: test1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
state DOWN mode DEFAULT
    link/ether 78:e7:d1:e4:9b:65 brd ff:ff:ff:ff:ff:ff
11: ;vdsmdummy;: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT
    link/ether 5e:b4:ac:5c:b9:a1 brd ff:ff:ff:ff:ff:ff
37: enp2s16f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether 00:00:00:00:00:02 brd ff:ff:ff:ff:ff:ff
38: enp2s16f3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether d6:ee:45:57:c0:39 brd ff:ff:ff:ff:ff:ff
39: enp2s16f5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether 4a:2c:25:42:97:4a brd ff:ff:ff:ff:ff:ff
40: enp2s16f7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether c2:fe:2f:5e:f5:e8 brd ff:ff:ff:ff:ff:ff
41: enp2s17f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
mode DEFAULT qlen 1000
    link/ether e6:31:a9:59:5f:ad brd ff:ff:ff:ff:ff:ff

enp2s0f1 is the physical function; enp2s1f* are the interfaces to the
virtual functions.

Essentially, I have 2 questions:
1) What is the difference between the entries under the physical
function and the interfaces?
2) How should I retrieve the correct MAC addresses? I'm aware of
/sys/.../<vf>/net/address, but I am now not sure it is the correct
source.

Thanks,
Leon
