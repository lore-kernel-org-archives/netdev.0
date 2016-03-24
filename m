From: Baozeng <sploving1@gmail.com>
Subject: Re: net/sctp: stack-out-of-bounds in sctp_getsockopt
Date: Thu, 24 Mar 2016 13:01:14 +0800
Message-ID: <CAP=GMUE3S5dxFu=r1XZWJzMeZ5XYriSQHY9-6YEbSFi4+j6wuA@mail.gmail.com>
References: <56f16034.890c620a.e04dc.ffffc770@mx.google.com>
	<1458660088.10868.19.camel@edumazet-glaptop3.roam.corp.google.com>
	<1458660478.10868.21.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAP=GMUFA-qAOxF1W=aeWDYBiR-GSohJYGHiMDsrqwsD0xdg3_Q@mail.gmail.com>
	<20160323173818.GA11724@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	marcelo.leitner@gmail.com,
	Vladislav Yasevich <vyasevich@gmail.com>,
	nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160323173818.GA11724@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-03-24 1:38 GMT+08:00, Pablo Neira Ayuso <pablo@netfilter.org>:
> On Thu, Mar 24, 2016 at 12:42:43AM +0800, Baozeng wrote:
>> 2016-03-22 23:27 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> > Untested patch would be :
>> >
>> > diff --git a/net/bridge/netfilter/ebtables.c
>> > b/net/bridge/netfilter/ebtables.c
>> > index 67b2e27999aa..fceb7354d169 100644
>> > --- a/net/bridge/netfilter/ebtables.c
>> > +++ b/net/bridge/netfilter/ebtables.c
>> > @@ -346,7 +346,7 @@ find_inlist_lock(struct list_head *head, const char
>> > *name, const char *prefix,
>> >  {
>> >         return try_then_request_module(
>> >                         find_inlist_lock_noload(head, name, error,
>> > mutex),
>> > -                       "%s%s", prefix, name);
>> > +                       "%.*s%s", EBT_TABLE_MAXNAMELEN, prefix, name);
>> >  }
>> >
>> >  static inline struct ebt_table *
>> >
>> >
>>
>> Thanks for your quick patch. I tested it but it still reproduce the
>> bug. We should limit the length of the name,
>> not the prefix. The following patch fixs it.
>
> Could you give a try to this patch? Thanks.
>

I tested with your patch. It fixs the bug. Thanks.

-- 
     Best Regards,
                                                                 Baozeng  Ding
