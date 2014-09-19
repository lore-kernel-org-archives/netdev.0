From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual device
Date: Fri, 19 Sep 2014 14:59:29 -0700
Message-ID: <CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	<1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:49485 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758070AbaISV7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:59:30 -0400
Received: by mail-la0-f41.google.com with SMTP id s18so3946490lam.14
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:59:29 -0700 (PDT)
In-Reply-To: <1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 2:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-09-19 at 14:24 -0700, Cong Wang wrote:
>> On Wed, Sep 17, 2014 at 1:08 AM, Nicolas Dichtel
>> <nicolas.dichtel@6wind.com> wrote:
>> > Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
>> > driver uses tx_queue_len of the master device as the limit of packets enqueuing.
>> > Problem is that virtual drivers have this value set to 0, thus all broadcast
>> > packets were rejected.
>> > Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
>> > of 1000 (also arbitrarily chosen).
>> >
>>
>> Hmm, why not manually set this tx_queue_len to fix it?
>>
>> At least fifo qdisc also uses tx_queue_len, and when you bond
>> you have to set it to non-zero.
>
>
> This is not true. We usually leave virtual devices with tx_queue_len to
> 0, otherwise you get a qdisc on them for nothing...

Yeah, actually it is 1 if tx_queue_len is 0, my memory mistaken.
But many virtual devices like veth call ether_setup() therefore have
tx_queue_len = 1000, not 0. dummy and bonding are 0 though.

>
> Only when you want to have say HTB on the bonding, you might need to
> change tx_queue_len

HTB by default creates a fifo qdisc.... same thing as above.

>
>>
>> I am not saying using this tx_queue_len is absolutely correct,
>> I am saying it may be expected to set tx_queue_len by yourself.
>
> I disagree.
>

Then fix these tx_queue_len = 0?
