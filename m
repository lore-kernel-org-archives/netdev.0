From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] net: adjust skb->truesize in ___pskb_trim()
Date: Thu, 27 Apr 2017 14:43:11 -0400
Message-ID: <CAF=yD-+0JrZZERqPfVNn=JQMZiT8M9nyrDjq6=GCQ+B+FwtGKg@mail.gmail.com>
References: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com> <CAAeHK+xTtA-L7VJsP9GXHpVD=o-WOEJ+xD_sJ4b4O-F_aZx_aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33317 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756225AbdD0Snw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 14:43:52 -0400
Received: by mail-io0-f196.google.com with SMTP id k87so5465956ioi.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 11:43:52 -0700 (PDT)
In-Reply-To: <CAAeHK+xTtA-L7VJsP9GXHpVD=o-WOEJ+xD_sJ4b4O-F_aZx_aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 1:08 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Apr 26, 2017 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
>> skb_try_coalesce() using syzkaller and a filter attached to a TCP
>> socket.
>>
>> As we did recently in commit 158f323b9868 ("net: adjust skb->truesize in
>> pskb_expand_head()") we can adjust skb->truesize from ___pskb_trim(),
>> via a call to skb_condense().
>>
>> If all frags were freed, then skb->truesize can be recomputed.
>>
>> This call can be done if skb is not yet owned, or destructor is
>> sock_edemux().
>
> Hi Eric,
>
> I still see the warning even with your patch.

Can this happen if sk_trim_filter_cap trims the skb to free some,
but not all, of the frags? If skb->data_len remains larger than
skb->end - skb->tail, skb_condense will not adjust the truesize.
