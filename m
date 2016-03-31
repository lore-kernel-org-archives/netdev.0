From: David Miller <davem@davemloft.net>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Thu, 31 Mar 2016 17:20:50 -0400 (EDT)
Message-ID: <20160331.172050.1423948167839485574.davem@davemloft.net>
References: <20160329224043.GY3784@sliepen.org>
	<CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guus@tinc-vpn.org, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932304AbcCaVUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 17:20:52 -0400
In-Reply-To: <CALx6S37xsTeDyMHOEiGzjpbR_5zFw6XSDEgPkZqpUzEa9WDStg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 31 Mar 2016 17:18:48 -0400

> On Tue, Mar 29, 2016 at 6:40 PM, Guus Sliepen <guus@tinc-vpn.org> wrote:
>> I'm trying to reduce system call overhead when reading/writing to/from a
>> tun device in userspace. For sockets, one can use sendmmsg()/recvmmsg(),
>> but a tun fd is not a socket fd, so this doesn't work. I'm see several
>> options to allow userspace to read/write multiple packets with one
>> syscall:
>>
>> - Implement a TX/RX ring buffer that is mmap()ed, like with AF_PACKET
>>   sockets.
>>
>> - Implement a ioctl() to emulate sendmmsg()/recvmmsg().
>>
>> - Add a flag that can be set using TUNSETIFF that makes regular
>>   read()/write() calls handle multiple packets in one go.
>>
>> - Expose a socket fd to userspace, so regular sendmmsg()/recvmmsg() can
>>   be used. There is tun_get_socket() which is used internally in the
>>   kernel, but this is not exposed to userspace, and doesn't look trivial
>>   to do either.
>>
>> What would be the right way to do this?
>>
> Personally I think tun could benefit greatly if it were implemented as
> a socket instead of character interface. One thing that could be much
> better is sending/receiving of meta data attached to skbuf. For
> instance GSO data could be in ancillary data in a socket instead of
> inline with packet data as tun seems to be doing now.

Agreed.
