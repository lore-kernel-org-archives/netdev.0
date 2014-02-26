From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: shutdown()'s 'how' parameter doesn't seem to be used correctly
Date: Wed, 26 Feb 2014 08:39:23 -0800
Message-ID: <1393432763.2316.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6CB847@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45903 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaBZQjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:39:25 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so100260pdb.28
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:39:24 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CB847@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 15:18 +0000, David Laight wrote:
> AFAICT userspace calls shutdown(sock, how) with 'how' set to one of SHUT_RD (0),
> SHUT_WR (1) or SHUT_RDWR(2).
> 
> The kernel code typically wants the bitmask of RCV_SHUTDOWN (1) | SEND_SHUTDOWN (2).
> If you look at the af_unix.c unix_shutdown() there is a comment where it
> add's one in order to do the conversion.
> 
> But I can't find the conversion before tcp_shutdown() or sctp_shutdown()
> checks for 'how & SEND_SHUTDOWN'.
> Which implies that shutdown(sock, SHUT_WR) doesn't work.
> 
> What have I missed?
> Should I be passing 2 or 3 to a direct call to sock->ops->shutdown()?
> (We currently pass 2 - which does outward disconnect anyway).

Take a look at inet_shutdown()
