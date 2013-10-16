From: Kyle Hubert <khubert@gmail.com>
Subject: Re: SW csum errors
Date: Wed, 16 Oct 2013 11:10:58 -0400
Message-ID: <CAJoZ4U0PNtk2e_x4D3N_fFN32uTVe6Z+FPg7ofG69KjQzsZ7xA@mail.gmail.com>
References: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
	<20131014135859.74f38507@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:60601 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab3JPPK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:10:59 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so732855qab.2
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:10:59 -0700 (PDT)
In-Reply-To: <20131014135859.74f38507@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 4:58 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 14 Oct 2013 16:13:15 -0400
> Kyle Hubert <khubert@gmail.com> wrote:
>
>> My problem is rather specific. I am working on an RDMA device, and we
>> have full end to end reliability. However, one of the initial spins of
>> our chip had some errors, since fixed, where the csum was unreliable.
>> So, we did exactly what Dave Miller warned not to do in the linked
>> message. We ran outgoing IP packets through the SKB checksum
>> function.. Unfortunately, we occasionally saw NFS csum errors on full
>> MTU packets.
>>
>> Here is his response:
>>
>> http://marc.info/?l=linux-netdev&m=128286758300676&w=2
>>
>> Relevant portion:
>>
>> "
>> Paged SKBs can have references to page cache pages and similar.  These
>> can be updated asynchronously to the transmit, there is no locking at
>> all to freeze the contents, and therefore full checksum offload is
>> required to support SG correctly.
>>
>> So don't get the idea to do the checksum in software in the infiniband
>> layer, and advertize hw checksumming support, to get around this :-)
>> "
>>
>> Now that those chips have long gone, I am left pondering about these
>> packets "corrupted" before the device transfers them. Can I get more
>> information about these paged SKBs with asynchronous modifications?
>> How does NFS use them?
>
> You would have to either mark the pages as copy on write or copy the data.
> Setting COW is expensive because you have to coordinate with other CPU's
> on SMP. Not sure exactly how.
>
> You can demonstrate this with either sendfile() or NFS where underlying
> file contents are being modified while packet is in the queue.

Thanks, I didn't realize it was as simple as file backed pages being
changed. Yes, our device does support SG, so we do have zero-copy
sendfile() support. I'll concoct a simple test to prove this.

-Kyle
