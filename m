From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: split up rxrpc_send_call_packet()
Date: Sat, 01 Oct 2016 00:35:09 +0100
Message-ID: <12692.1475278509@warthog.procyon.org.uk>
References: <20160930161218.4178124-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750873AbcI3XfN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 19:35:13 -0400
In-Reply-To: <20160930161218.4178124-1-arnd@arndb.de>
Content-ID: <12691.1475278509.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:

> A number of reworks went into rxrpc_send_call_packet() recently, which
> introduced another warning when built with -Wmaybe-uninitialized:
> 
> In file included from ../net/rxrpc/output.c:20:0:
> net/rxrpc/output.c: In function 'rxrpc_send_call_packet':
> net/rxrpc/ar-internal.h:1187:27: error: 'top' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> net/rxrpc/output.c:103:24: note: 'top' was declared here
> net/rxrpc/output.c:225:25: error: 'hard_ack' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This is a false positive, but it's also an indication that the function is
> getting complex enough that the compiler cannot figure out what it does.
> 
> This splits out a rxrpc_send_ack_packet() function for one part of
> it, making it more understandable by both humans and the compiler
> and avoiding the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Unfortunately, this is a larger rework that I was hoping for, and
> I have only build tested it, so please review carefully, or just
> discard it and treat it as feedback to the original patch.

I think I'd rather cleanly split it into two transmission functions.  I'll do
that.

Thanks,
David
