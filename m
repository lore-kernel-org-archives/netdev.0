From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: loading ip_vti breaks IPSec connection
Date: Mon, 15 Sep 2014 17:31:05 +0200
Message-ID: <CADdy8Hqb-7Q3jShq1-NbUtwVW9XbC8eKYa5B0E8g1g6CMTHbVg@mail.gmail.com>
References: <CAHjjW16qJgU+cf2-fowyJMRioc61Ko8KF65Qp5Npw9DsoF95VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe M <joe9mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:47570 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224AbaIOPbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:31:07 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so4130369igd.2
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 08:31:05 -0700 (PDT)
In-Reply-To: <CAHjjW16qJgU+cf2-fowyJMRioc61Ko8KF65Qp5Npw9DsoF95VA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-09-13 5:39 GMT+02:00 Joe M <joe9mail@gmail.com>:
> Hello,
>
> I am not sure what I am missing. When I load ip_vti and ip_tunnel
> modules, my IPSec connection stops working.
>
> uname -a
> Linux master 3.16.2 #86 SMP PREEMPT Fri Sep 12 22:09:11 CDT 2014
> x86_64 Intel(R) Pentium(R) CPU G620 @ 2.60GHz GenuineIntel GNU/Linux
>
> - (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
> sudo modprobe ip_vti ip_tunnel
> - (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
> ping -c 1 -I 192.168.0.11 192.168.1.232
> PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.
>
> --- 192.168.1.232 ping statistics ---
> 1 packets transmitted, 0 received, 100% packet loss, time 0ms
>
> - (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
> sudo modprobe --force --remove ip_vti ip_tunnel
> - (0:c:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
> ping -c 1 -I 192.168.0.11 192.168.1.232
> PING 192.168.1.232 (192.168.1.232) from 192.168.0.11 : 56(84) bytes of data.
> 64 bytes from 192.168.1.232: icmp_seq=1 ttl=64 time=273 ms
>
> --- 192.168.1.232 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 273.347/273.347/273.347/0.000 ms
> - (0:i:/tmp)  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
>
> Please note that the module was just loaded without any tunnel
> configuration. I am not sure
>
> I am using StrongSwan for IPSec configuration and noticed the same
> behaviour with libreswan too.

Hi Joe,

I never experienced such problem.

To be sure, I did a test in tunnel mode with strongswan 5.1.2 on an
ubuntu 14.04 + vanilla Linux 3.17.0-rc5, and could not reproduce your
problem.

> Please let me know if I can provide more details.

Are you using the unchanged kernel image of your distribution, or a
kernel you compiled?

By the way, was your IPsec tunnel already established when you
executed your first ping? the first packet that triggers an IKE
negotiation is always lost.

Regards,
Christophe

> Thanks
> Joe
