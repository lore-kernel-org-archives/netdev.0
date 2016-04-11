From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Getting at the UDP headers from ->data_ready()
Date: Mon, 11 Apr 2016 17:18:40 -0400
Message-ID: <CAF=yD-JfW6kfoQ4geO3bCCrBVng-AL=BqBuVyF2nU0tO4jpsDg@mail.gmail.com>
References: <19466.1460408649@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:34158 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcDKVTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 17:19:21 -0400
Received: by mail-lf0-f51.google.com with SMTP id j11so175168016lfb.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 14:19:20 -0700 (PDT)
In-Reply-To: <19466.1460408649@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 5:04 PM, David Howells <dhowells@redhat.com> wrote:
> Hi Willem,
>
> With regards to:
>
>     commit 4d0fc73ebe94ac984a187f21fbf4f3a1ac846f5a
>     Author: Willem de Bruijn <willemb@google.com>
>     Date:   Thu Apr 7 11:44:59 2016 -0400
>
>     rxrpc: do not pull udp headers on receive
>
>     Commit e6afc8ace6dd modified the udp receive path by pulling the udp
>     header before queuing an skbuff onto the receive queue.
>
> Does that mean that I can no longer access the UDP header via udp_hdr(skb)
> from with the ->data_ready() handler?
>
> I'm guessing that's not actually the case since ip_hdr(skb) seems to work - or
> is that something I shouldn't be using since the part of the buffer containing
> the IP header might've been discarded?

The network and transport header pointers are still valid. Commit e6afc8ace6dd
only  changes where skb->data points to. It does not discard the data between
skb->head and skb->data. This rxrpc follow-up patch fixes some offset
arithmetic to the payload, which is computed relative to skb->data.

There are other uses of ip_hdr and udp_hdr in udp_recvmsg and similar
recvmsg handlers for other protocols. For instance, in the source address
processing for recvfrom ("if (sin) { .. }")
