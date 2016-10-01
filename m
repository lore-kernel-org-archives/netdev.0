From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rxrpc: split up rxrpc_send_call_packet()
Date: Sat, 1 Oct 2016 05:40:58 +0200
Message-ID: <201610010540.58123.arnd@arndb.de>
References: <12692.1475278509@warthog.procyon.org.uk> <20160930161218.4178124-1-arnd@arndb.de> <16139.1475279560@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:54971 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbcJADlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 23:41:14 -0400
In-Reply-To: <16139.1475279560@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 01 October 2016, David Howells wrote:
> commit 35510eefc29e2757c1ac46218cded2e505093fc2
> Author: David Howells <dhowells@redhat.com>
> Date:   Sat Oct 1 00:35:15 2016 +0100
> 
>     rxrpc: Split rxrpc_send_call_packet()
>     
>     Split rxrpc_send_data_packet() to separate ACK generation (which is more
>     complicated) from ABORT generation.  This simplifies the code a bit and
>     avoids the following warning:
>     
>     In file included from ../net/rxrpc/output.c:20:0:
>     net/rxrpc/output.c: In function 'rxrpc_send_call_packet':
>     net/rxrpc/ar-internal.h:1187:27: error: 'top' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     net/rxrpc/output.c:103:24: note: 'top' was declared here
>     net/rxrpc/output.c:225:25: error: 'hard_ack' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     
>     Reported-by: Arnd Bergmann <arnd@arndb.de>
>     Signed-off-by: David Howells <dhowells@redhat.com>

Yes, good idea. We could probably share the part of the two functions that sets the
contents of the msg and pkt variables by moving it into a third function, but I'm
not sure if that actually improves readability or just reduces the number of lines.

	Arnd 
