From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Fri, 4 Mar 2016 11:33:36 -0500
Message-ID: <CAF=yD-LyNo_tXu_D=MG3U7aXgU6MrV0i1YkrCHDFRufq9QMaHw@mail.gmail.com>
References: <20160225.152628.1230785666614750970.davem@davemloft.net>
 <1456497874.7064.7.camel@linux.intel.com> <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
 <20160226.124645.2123990166666725876.davem@davemloft.net> <CAF=yD-+m09_KS9+SyMZsTES5iLPyVE10F0u6pt4tVeYcDk8=PQ@mail.gmail.com>
 <1456876822.7064.36.camel@linux.intel.com> <CAF=yD-+mNY0g4A8oWJEWPDeAuucrJX-E1pNd6ABYK+BzmrKvOQ@mail.gmail.com>
 <CAF=yD-+-QFp=g8BSsxjwwMmMwuHzkEiubZHNuyoLccF7qTs0ow@mail.gmail.com> <1457106849.7064.55.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Heikki Hannikainen <hessu@hes.iki.fi>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:33885 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759524AbcCDQeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:34:18 -0500
Received: by mail-lb0-f175.google.com with SMTP id cf7so50900445lbb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:34:17 -0800 (PST)
In-Reply-To: <1457106849.7064.55.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 10:54 AM, Alan Cox <alan@linux.intel.com> wrote:
>> > A quick search for ethhdr in drivers/net/ethernet shows, for
>> > instance,
>> > bnx2x_select_queue casting skb->data to an ethernet header. Reading
>> > nonsense in that particular function is quite safe and given the
>> > skbuff layout (skb_shared_info) code will never read beyond an
>> > allocated region. But that was just the first occurrence I found.
>> > efx_tso_check_protocol is another example.
>
> So would always allocating that much space be a good mitigation in
> general

Agreed. The existing packet allocation path does that by relying on
LL_RESERVED_SPACE on allocation, not only packet length. I won't
modify that. But I should perhaps zero up to hard_header_len on
variable length headers.

>  and perhaps then making the logic check validate() IFF
> CAP_SYS_RAWIO is not set.
>
> A user with CAP_SYS_RAWIO already has the power to control the device
> by banging registers so the check is not a security loss.

One concern is namespaces. I'll use capable(CAP_SYS_RAWIO), not ns_capable.

Need to add an ax25_validate implemention and run some tests before I
send out the patch.

Thanks,

  Willem
