From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sat, 13 Apr 2013 20:49:56 -0400
Message-ID: <CA+FuTScTDYreuynVhFLnPb12YgMPJ2oW=6F+esDTtTRp3RNB_g@mail.gmail.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com>
 <20130413.184727.1419644906707693070.davem@davemloft.net> <CA+FuTScq=jjMddio=CgzS=mbqDEtg8NHhi8nx+jK0DutRvLLeA@mail.gmail.com>
 <CA+FuTSeEhJvatV-BzDo6pPTZ+1wucVt-4btwAOT5p8rT99+d9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:52487 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab3DNAu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 20:50:27 -0400
Received: by mail-ie0-f170.google.com with SMTP id c11so4665361ieb.1
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 17:50:26 -0700 (PDT)
In-Reply-To: <CA+FuTSeEhJvatV-BzDo6pPTZ+1wucVt-4btwAOT5p8rT99+d9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 13, 2013 at 8:16 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Sat, Apr 13, 2013 at 8:04 PM, Willem de Bruijn <willemb@google.com> wrote:
>> On Sat, Apr 13, 2013 at 6:47 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Daniel Borkmann <dborkman@redhat.com>
>>> Date: Sun, 14 Apr 2013 00:18:48 +0200
>>>
>>>>> +            flush_dcache_page(pgv_to_page(&h1->tp_sec));
>>>>> +            flush_dcache_page(pgv_to_page(&h1->tp_usec));
>>>>
>>>> Hmm, not sure, but could we also flush the dcache only once?
>>>
>>> Indeed, I truly hope that headers never straddle pages.
>>
>> I should have checked the alignment restrictions on frames. Frames
>> must be a multiple of 16 B as well as larger than the header (obviously),
>> so this can indeed never happen.
>
> Actually, 48 B is a multiple of 16, so should be accepted, and 85
> frames on a page leaves half a frame for the next. I'll check whether
> this is right. Even if so, it would still not matter for these time
> offsets, as they start at 16 or 20 B offset from the start of the
> frame.

48 B is too small (Because less than TPACKET_HDRLEN), but it can
be triggered with 80 B frames. Daniel, thanks for submitting the
selftest: both the timestamp and this alignment question were now very
easy to test by just changing a few lines in your code.
