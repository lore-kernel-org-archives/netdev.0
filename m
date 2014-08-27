From: Tushar Shinde <mtk.tushar@gmail.com>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 19:11:14 +0530
Message-ID: <CABQpAL4tpfAXNbk7AgqV-FZKSSAMVYN_jvOkj58Sc719xKxB-g@mail.gmail.com>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	<1409090482.1152.8.camel@localhost>
	<CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
	<1409118957.11976.9.camel@localhost>
	<CABQpAL4zbeqX4X1Kuzw-+FOppmYx7VzTzJn9OMLyYVBdS0Bz9w@mail.gmail.com>
	<1409119546.11976.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:57039 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933583AbaH0NlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 09:41:15 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so5871184wiv.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:41:14 -0700 (PDT)
In-Reply-To: <1409119546.11976.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping6 command uses SO_BINDTODEVICE but it looks it is not working. The
source address in fib6 rule match is 0:::0

strace ping6 -I eth0 2001:2::20 2> t
socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 4
setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, "eth0\0", 5) = 0
connect(4, {sa_family=AF_INET6, sin6_port=htons(1025),
inet_pton(AF_INET6, "2001:2::20", &sin6_addr), sin6_flowinfo=0,
sin6_scope_id=0}, 28) = -1 ENETUNREACH (Network is unreachable)

I think there is problem with so_binddevice. need to dig further.

Tushar




On Wed, Aug 27, 2014 at 11:35 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mi, 2014-08-27 at 11:32 +0530, Tushar Shinde wrote:
>> So do we need to always use ipv6 address to bind unlike ipv4?
>
> No, I think SO_BINDTODEVICE should work. But ping6 does not use it, so
> one could add support for this to ping with a new option.
>
> ping6 uses cmsg with undefined ipv6 source address but set ifindex and
> that's not at all like SO_BINDTODEVICE.
>
> Bye,
> Hannes
>
>
