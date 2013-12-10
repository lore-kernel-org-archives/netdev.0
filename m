From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: ifconfig doesn't show assignment ip-addresses
Date: Tue, 10 Dec 2013 12:06:49 +0100
Message-ID: <20131210110648.GA18196@omega>
References: <20131209153238.GA10317@omega>
 <20131210105741.GA2469@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:63556 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab3LJLG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 06:06:59 -0500
Received: by mail-wg0-f52.google.com with SMTP id x13so4781524wgg.7
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 03:06:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131210105741.GA2469@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

thanks for your reply.

On Tue, Dec 10, 2013 at 11:57:41AM +0100, Jiri Pirko wrote:
> Mon, Dec 09, 2013 at 04:32:39PM CET, alex.aring@gmail.com wrote:
> >Hi,
> >
> >On current net-next with a lowpan interface created with:
> >
> >ip link add link wpan0 name lowpan0 type lowpan
> >
> >I don't see any ipv6 addresses in ifconfig anymore. The addresses exist,
> >because I can ping my device.
> 
> 
> Can you see the address in "ip a" ? Would you send me output of
> "ifconfig" and "ip a" please? Is this a problem for lowpan only or do
> you see this with other device types as well?
> 

Yes I can see the address in "ip a".

Output of "ip a":

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
    inet6 2001::2/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 2001::3/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe12:3456/64 scope link 
       valid_lft forever preferred_lft forever
3: sit0: <NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 brd 0.0.0.0
4: wpan0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 127 qdisc pfifo_fast qlen 300
    link/[804] aa:aa:aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff:ff:ff
5: lowpan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1281 qdisc noqueue 
    link/[804] aa:aa:aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff:ff:ff
    inet6 2001::1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::1/64 scope link 
       valid_lft forever preferred_lft forever
    inet6 fe80::a8aa:aaaa:aaaa:aaaa/64 scope link 
       valid_lft forever preferred_lft forever

Output of "ifconfig":

eth0      Link encap:Ethernet  HWaddr 52:54:00:12:34:56  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:1144 (1.1 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lowpan0   Link encap:UNSPEC  HWaddr AA-AA-AA-AA-AA-AA-AA-AA-00-00-00-00-00-00-00-00  
          UP BROADCAST RUNNING MULTICAST  MTU:1281  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

wpan0     Link encap:UNSPEC  HWaddr AA-AA-AA-AA-AA-AA-AA-AA-00-00-00-00-00-00-00-00  
          UP BROADCAST RUNNING NOARP  MTU:127  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:300 
          RX bytes:0 (0.0 B)  TX bytes:597 (597.0 B)

So i can't see any inet6 addresses on eth0 interface, so maybe it isn't
a lowpan specific problem.

I use ip/ifconfig from busybox at version:

BusyBox v1.20.2 (2013-11-16 07:37:30 CET) multi-call binary.

- Alex
