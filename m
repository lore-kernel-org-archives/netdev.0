From: Kyle Hubert <khubert@gmail.com>
Subject: SW csum errors
Date: Mon, 14 Oct 2013 16:13:15 -0400
Message-ID: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:63493 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758312Ab3JNUNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 16:13:16 -0400
Received: by mail-qc0-f170.google.com with SMTP id n9so2285477qcw.29
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 13:13:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My problem is rather specific. I am working on an RDMA device, and we
have full end to end reliability. However, one of the initial spins of
our chip had some errors, since fixed, where the csum was unreliable.
So, we did exactly what Dave Miller warned not to do in the linked
message. We ran outgoing IP packets through the SKB checksum
function.. Unfortunately, we occasionally saw NFS csum errors on full
MTU packets.

Here is his response:

http://marc.info/?l=linux-netdev&m=128286758300676&w=2

Relevant portion:

"
Paged SKBs can have references to page cache pages and similar.  These
can be updated asynchronously to the transmit, there is no locking at
all to freeze the contents, and therefore full checksum offload is
required to support SG correctly.

So don't get the idea to do the checksum in software in the infiniband
layer, and advertize hw checksumming support, to get around this :-)
"

Now that those chips have long gone, I am left pondering about these
packets "corrupted" before the device transfers them. Can I get more
information about these paged SKBs with asynchronous modifications?
How does NFS use them?

Thanks for your time,
-Kyle
