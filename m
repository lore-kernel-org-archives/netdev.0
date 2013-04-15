From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 13:08:52 -0400
Message-ID: <CA+FuTSedhCD2_uWL17bNSjDG5+3RhagkjFCVMcOx9G4H7byi2g@mail.gmail.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B71D1@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:63131 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3DORJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:09:22 -0400
Received: by mail-ie0-f177.google.com with SMTP id 9so5586610iec.8
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 10:09:22 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71D1@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 5:45 AM, David Laight <David.Laight@aculab.com> wrote:
>> > +   case TPACKET_V1:
>> > +           h1 = frame;
>> > +           h1->tp_sec = ts.tv_sec;
>> > +           h1->tp_usec = ts.tv_nsec / NSEC_PER_USEC;
>> > +
>> > +           flush_dcache_page(pgv_to_page(&h1->tp_sec));
>> > +           flush_dcache_page(pgv_to_page(&h1->tp_usec));
>>
>> Hmm, not sure, but could we also flush the dcache only once?
>
> If it isn't a silly question, why is the dcache being flushed
> here at all?

I'm not an expert on this, but have a look at
Documentation/cachetlb.txt, specifically the bits on this function and
the discussion of aliasing: on virtually indexed cache architectures,
the same physical address may be cached in multiple cachelines at the
same time. If I understand correctly, updating the kernel logical
address does not necessarily invalidate the user virtual cacheline for
the same physical memory.

>         David
>
>
>
