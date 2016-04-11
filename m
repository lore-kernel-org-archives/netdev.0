From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Mon, 11 Apr 2016 15:02:51 -0700
Message-ID: <CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sagi Grimberg <sagi@grimberg.me>,
	Bart Van Assche <bart.vanassche@sandisk.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34432 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbcDKWCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 18:02:52 -0400
Received: by mail-io0-f182.google.com with SMTP id 2so4484711ioy.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 15:02:51 -0700 (PDT)
In-Reply-To: <20160411234157.3fc9c6fe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 2:41 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:
>
>> >> This is also very interesting for storage targets, which face the same
>> >> issue.  SCST has a mode where it caches some fully constructed SGLs,
>> >> which is probably very similar to what NICs want to do.
>> >
>> > I think a cached allocator for page sets + the scatterlists that
>> > describe these page sets would not only be useful for SCSI target
>> > implementations but also for the Linux SCSI initiator. Today the scsi-mq
>> > code reserves space in each scsi_cmnd for a scatterlist of
>> > SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
>> > sets less memory would be needed per scsi_cmnd.
>>
>> If we go down this road how about also attaching some driver opaques
>> to the page sets?
>
> That was the ultimate plan... to leave some opaques bytes left in the
> page struct that drivers could use.
>
> In struct page I would need a pointer back to my page_pool struct and a
> page flag.  Then, I would need room to store the dma_unmap address.
> (And then some of the usual fields are still needed, like the refcnt,
> and reusing some of the list constructs).  And a zero-copy cross-domain
> id.
>
>
> For my packet-page idea, I would need a packet length and an offset
> where data starts (I can derive the "head-room" for encap from these
> two).

Have you taken a look at possibly trying to optimize the DMA pool API
to work with pages?  It sounds like it is supposed to do something
similar to what you are wanting to do.

- Alex
