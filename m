From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SW csum errors
Date: Mon, 14 Oct 2013 13:40:06 -0700
Message-ID: <1381783206.2045.3.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle Hubert <khubert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:62341 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106Ab3JNUkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 16:40:08 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so7800980pbc.3
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 13:40:07 -0700 (PDT)
In-Reply-To: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-14 at 16:13 -0400, Kyle Hubert wrote:
> My problem is rather specific. I am working on an RDMA device, and we
> have full end to end reliability. However, one of the initial spins of
> our chip had some errors, since fixed, where the csum was unreliable.
> So, we did exactly what Dave Miller warned not to do in the linked
> message. We ran outgoing IP packets through the SKB checksum
> function.. Unfortunately, we occasionally saw NFS csum errors on full
> MTU packets.
> 
> Here is his response:
> 
> http://marc.info/?l=linux-netdev&m=128286758300676&w=2
> 
> Relevant portion:
> 
> "
> Paged SKBs can have references to page cache pages and similar.  These
> can be updated asynchronously to the transmit, there is no locking at
> all to freeze the contents, and therefore full checksum offload is
> required to support SG correctly.
> 
> So don't get the idea to do the checksum in software in the infiniband
> layer, and advertize hw checksumming support, to get around this :-)
> "
> 
> Now that those chips have long gone, I am left pondering about these
> packets "corrupted" before the device transfers them. Can I get more
> information about these paged SKBs with asynchronous modifications?
> How does NFS use them?

For a start try :

git grep -n SKBTX_SHARED_FRAG
git grep -n skb_has_shared_frag

git show cef401de7be8c4e
git show c9af6db4c11ccc6
