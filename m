From: lin zhang <xiaolou4617@gmail.com>
Subject: Re: [PATCH net-next] skbuff: optimize the pull_pages code in __pskb_pull_tail()
Date: Thu, 6 Jul 2017 17:35:35 +0800
Message-ID: <CAGd-6ZeegG2wRg19kNs6ZzEMxtXKMKUL2+=AiTjHOxNDDGM6RQ@mail.gmail.com>
References: <1499331694-34678-1-git-send-email-xiaolou4617@gmail.com>
 <1499332587.16045.13.camel@edumazet-glaptop3.roam.corp.google.com> <1499333003.16045.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499333003.16045.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-07-06 17:23 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2017-07-06 at 02:16 -0700, Eric Dumazet wrote:
>> On Thu, 2017-07-06 at 17:01 +0800, Lin Zhang wrote:
>> > In the pull_pages code block, if the first frags size > eat,
>> > we can end the loop in advance to avoid extra copy.
>> >
>> > Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
>> > ---
>> >  net/core/skbuff.c | 4 ++++
>> >  1 file changed, 4 insertions(+)
>> >
>> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> > index f990eb8..c00a1df 100644
>> > --- a/net/core/skbuff.c
>> > +++ b/net/core/skbuff.c
>> > @@ -1720,6 +1720,10 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
>> >                             skb_shinfo(skb)->frags[k].page_offset += eat;
>> >                             skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
>> >                             eat = 0;
>> > +                           if (!i) {
>> > +                                   k = skb_shinfo(skb)->nr_frags;
>> > +                                   break;
>> > +                           }
>> >                     }
>> >                     k++;
>> >             }
>>
>> 1) net-next is closed during merge window.
>>
>> 2) This change is completely buggy.
>>    How have you tested it exactly ???
>
> Hmm... it looks like I was wrong, but 1) still applies ;)
>
>
>
>
thanks, i am a newer, "net-next is closed" it means i need repost it
after net-next reopened?

regards
-- 
Lin Zhang
