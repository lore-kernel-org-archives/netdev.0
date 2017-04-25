From: Willem de Bruijn <willemb@google.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Tue, 25 Apr 2017 13:23:41 -0400
Message-ID: <CA+FuTScs9Kp4=Grr+b3HMVg_rGJ8kWYvDDN4kpbFQ0mpS6UdnA@mail.gmail.com>
References: <20170412141737.5881-1-mlichvar@redhat.com> <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
 <20170413151806.GA26613@localhost> <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
 <20170424090043.GF8847@localhost> <CAF=yD-+ErPH6Qb4y9TcAMi-7X+ebxW3epq3Zxch_vrt1r3gspQ@mail.gmail.com>
 <20170425135642.GB27148@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35247 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951948AbdDYRYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:24:13 -0400
Received: by mail-wm0-f42.google.com with SMTP id w64so29012978wma.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:24:12 -0700 (PDT)
In-Reply-To: <20170425135642.GB27148@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 9:56 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Mon, Apr 24, 2017 at 11:18:13AM -0400, Willem de Bruijn wrote:
>> On Mon, Apr 24, 2017 at 5:00 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > Would "skb->data - skb->head -
>> > skb->mac_header + skb->len" always work as the L2 length for received
>> > packets at the time when the cmsg is prepared?
>>
>> (skb->data - skb->head) - skb->mac_header computes the length
>> of data before the mac, such as reserve?
>
> data - head includes the reserve, but mac_header does too, so I think
> it should be just the length of MAC header and everything up to the
> data.
>
>> Do you mean skb->data -
>> skb->mac_header (or - skb_mac_offset(skb))?
>
> That would give me a pointer? If I used skb_mac_offset(), the total
> length would be just skb->len - skb_mac_offset()?

It appears so. The only existing caller first checks
skb_mac_header_was_set(skb).
