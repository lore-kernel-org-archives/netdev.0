From: Tom Herbert <tom@herbertland.com>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Thu, 31 Mar 2016 17:18:48 -0400
Message-ID: <CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
References: <20160329224043.GY3784@sliepen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guus Sliepen <guus@tinc-vpn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33763 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832AbcCaVSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 17:18:49 -0400
Received: by mail-ig0-f176.google.com with SMTP id ma7so1042290igc.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 14:18:49 -0700 (PDT)
In-Reply-To: <20160329224043.GY3784@sliepen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 6:40 PM, Guus Sliepen <guus@tinc-vpn.org> wrote:
> I'm trying to reduce system call overhead when reading/writing to/from a
> tun device in userspace. For sockets, one can use sendmmsg()/recvmmsg(),
> but a tun fd is not a socket fd, so this doesn't work. I'm see several
> options to allow userspace to read/write multiple packets with one
> syscall:
>
> - Implement a TX/RX ring buffer that is mmap()ed, like with AF_PACKET
>   sockets.
>
> - Implement a ioctl() to emulate sendmmsg()/recvmmsg().
>
> - Add a flag that can be set using TUNSETIFF that makes regular
>   read()/write() calls handle multiple packets in one go.
>
> - Expose a socket fd to userspace, so regular sendmmsg()/recvmmsg() can
>   be used. There is tun_get_socket() which is used internally in the
>   kernel, but this is not exposed to userspace, and doesn't look trivial
>   to do either.
>
> What would be the right way to do this?
>
Personally I think tun could benefit greatly if it were implemented as
a socket instead of character interface. One thing that could be much
better is sending/receiving of meta data attached to skbuf. For
instance GSO data could be in ancillary data in a socket instead of
inline with packet data as tun seems to be doing now.

Tom

> --
> Met vriendelijke groet / with kind regards,
>      Guus Sliepen <guus@tinc-vpn.org>
