From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: SW csum errors
Date: Mon, 14 Oct 2013 13:58:59 -0700
Message-ID: <20131014135859.74f38507@nehalam.linuxnetplumber.net>
References: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyle Hubert <khubert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:56717 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757090Ab3JNU7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 16:59:03 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so8077372pad.9
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 13:59:02 -0700 (PDT)
In-Reply-To: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Oct 2013 16:13:15 -0400
Kyle Hubert <khubert@gmail.com> wrote:

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

You would have to either mark the pages as copy on write or copy the data.
Setting COW is expensive because you have to coordinate with other CPU's
on SMP. Not sure exactly how.

You can demonstrate this with either sendfile() or NFS where underlying
file contents are being modified while packet is in the queue.
