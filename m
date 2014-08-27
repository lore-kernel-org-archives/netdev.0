From: Tushar Shinde <mtk.tushar@gmail.com>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 10:24:21 +0530
Message-ID: <CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	<1409090482.1152.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:63800 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbaH0EyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 00:54:22 -0400
Received: by mail-we0-f180.google.com with SMTP id w61so15569161wes.39
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 21:54:21 -0700 (PDT)
In-Reply-To: <1409090482.1152.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

Thank you for reply.

I tested it will 2 kernels 2.6.32-431.11.2.el6.x86_64, and ubuntu
14.04 kernel 3.13.

ping6 -I <IPv6 src ip> <dest> is working. I also verified ssh with -b working.

So my question is, is it necessary to give bind address to make source
based routing work? why don't it select ip address of given bind
interface? Because of this SO_BINDTODEVICE may not work as expected.

Tushar


On Wed, Aug 27, 2014 at 3:31 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi,
>
> On Di, 2014-08-26 at 21:32 +0530, Tushar Shinde wrote:
>> Hello NetDev,
>>
>> I am facing problem where if ipv6 route (outside to current subnet) is
>> reachable only if route is present in main table. Policy based routes
>> are not working.
>>
>> Following is my setup,
>>
>> eth0   inet6 2001:1::10/120 scope global
>> eth1   inet6 2001:1::11/120 scope global
>> 2001:1::1 is gateway
>> 2.6.32-431.11.2.el6.x86_64 kernel (I tried on 3.x also)
>>
>> [root@ipv6node1 ~]# ip -6 route show tab 1
>> 2001:1::/120 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
>> default via 2001:1::1 dev eth0  metric 1024  mtu 1500 advmss 1440
>> hoplimit 4294967295
>> [root@ipv6node1 ~]#
>> [root@ipv6node1 ~]# ip -6 route show tab 2
>> 2001:1::/120 dev eth1  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
>> default via 2001:1::1 dev eth1  metric 1024  mtu 1500 advmss 1440
>> hoplimit 4294967295
>> [root@ipv6node1 ~]#
>> [root@ipv6node1 ~]# ip -6 rule show
>> 0:    from all lookup local
>> 16383:    from 2001:1::10 lookup 1
>> 16383:    from 2001:1::11 lookup 2
>> 32766:    from all lookup main
>> [root@ipv6node1 ~]#
>>
>> If I add default vai eth0 only ip of eth0 is reachable from outside or
>> eth1 dont work. In above setup default route is not present.
>>
>> But default entry in "table" is never getting used to resolve route
>>
>> [root@ipv6node1 ~]# ping6 -I eth0 2001:2::20
>> connect: Network is unreachable
>> [root@ipv6node1 ~]#
>> [root@ipv6node1 ~]# ping6 -I eth1 2001:2::20
>> connect: Network is unreachable
>> [root@ipv6node1 ~]#
>
> ping6 selects the ipv6 address based on netlink route lookup given the
> specified interface but without setting the source address. That said,
> it is probable that the rule lookup happens with a completely different
> ipv6 address. Please verify this. ping6 -I also accepts a source ipv6
> address, can you try this?
>
> Otherwise please specify with which 3.x kernel you tested this.
>
> Thanks,
> Hannes
>
>
