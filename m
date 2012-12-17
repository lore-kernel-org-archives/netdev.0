From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: Whence a description of how to enable TCP FASTOPEN in a
 net-next kernel?
Date: Mon, 17 Dec 2012 14:03:54 -0800
Message-ID: <1355781834.9380.13.camel@edumazet-glaptop>
References: <50CF8E2A.5020201@hp.com>
	 <1355781411.9380.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38482 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab2LQWD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 17:03:57 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4328851pbc.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 14:03:57 -0800 (PST)
In-Reply-To: <1355781411.9380.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-17 at 13:56 -0800, Eric Dumazet wrote:

> 
> I guess you need to enable fastopen both for client and server :
> 
> echo 3 >/proc/sys//net/ipv4/tcp_fastopen

vi +475 Documentation/networking/ip-sysctl.txt

tcp_fastopen - INTEGER
        Enable TCP Fast Open feature (draft-ietf-tcpm-fastopen) to send data
        in the opening SYN packet. To use this feature, the client application
        must use sendmsg() or sendto() with MSG_FASTOPEN flag rather than
        connect() to perform a TCP handshake automatically.

        The values (bitmap) are
        1: Enables sending data in the opening SYN on the client.
        2: Enables TCP Fast Open on the server side, i.e., allowing data in
           a SYN packet to be accepted and passed to the application before
           3-way hand shake finishes.
        4: Send data in the opening SYN regardless of cookie availability and
           without a cookie option.
        0x100: Accept SYN data w/o validating the cookie.
        0x200: Accept data-in-SYN w/o any cookie option present.
        0x400/0x800: Enable Fast Open on all listeners regardless of the
           TCP_FASTOPEN socket option. The two different flags designate two
           different ways of setting max_qlen without the TCP_FASTOPEN socket
           option.

        Default: 0

        Note that the client & server side Fast Open flags (1 and 2
        respectively) must be also enabled before the rest of flags can take
        effect.

        See include/net/tcp.h and the code for more details.
