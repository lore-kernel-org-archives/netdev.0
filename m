From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Thu, 27 Apr 2017 12:21:00 -0400
Message-ID: <CAF=yD-+HK-dCG_XjqBKfkSF1bjJavTr7EFgeFNH2yRc2CXgOxA@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com> <20170427161700.GB3401@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33482 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751819AbdD0QVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:21:42 -0400
Received: by mail-io0-f196.google.com with SMTP id k87so4500193ioi.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 09:21:42 -0700 (PDT)
In-Reply-To: <20170427161700.GB3401@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > @@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>> >                 empty = 0;
>> >         if (shhwtstamps &&
>> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
>> > +           (empty || !skb_is_err_queue(skb)) &&
>> >             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
>>
>> I find skb->tstamp == 0 easier to understand than the condition on empty.
>>
>> Indeed, this is so non-obvious that I would suggest another helper function
>> skb_is_hwtx_tstamp with a concise comment about the race condition
>> between tx software and hardware timestamps (as in the last sentence of
>> the commit message).
>
> Should it include also the skb_is_err_queue() check? If it returned
> true for both TX and RX HW timestamps, maybe it could be called
> skb_has_hw_tstamp?

For the purpose of documenting why this complex condition exists,
I would call the skb_is_err_queue in that helper function and make
it tx + hw specific.
