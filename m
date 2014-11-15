From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 16:15:21 -0800
Message-ID: <CA+mtBx8-G4Dh_Zu87TKja-gSV_sctJopoJYsZqL4W1XmWkP7fA@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
	<CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
	<1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
	<CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
	<1416003371.17262.66.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALCETrVQqsJKqVU4ENEfi86wkQLQ=mqBif=HcQiKT2h_fj22xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrVQqsJKqVU4ENEfi86wkQLQ=mqBif=HcQiKT2h_fj22xQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 2:18 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Nov 14, 2014 at 2:16 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Fri, 2014-11-14 at 12:16 -0800, Andy Lutomirski wrote:
>>
>>> Sure, but how do I know that it'll be the same CPU next time?
>>
>> Because the NIC always use same RX queue for a given flow.
>>
>> So if you setup your IRQ affinities properly, the same CPU will drain
>> packets from this RX queue. And since RFS is off, you have the guarantee
>> the same CPU will be used to process packets in TCP stack.
>
> Right.  My concern is that if RFS is off, everything works fine, but
> if RFS is on (and the app has no good way to know), then silly results
> will happen.  I think I'd rather have the getsockopt fail if RFS is on
> or at least give some indication so that the app can react
> accordingly.
>
As I mentioned, there is no material functionality in this patch and
it should be independent of RFS. It simply returns the CPU where the
stack processed the packet. Whether or not this is meaningful
information to the algorithm being implemented in userspace is
completely up to the caller to decide.

Tom

> --Andy
>
>>
>> This SO_INCOMING_CPU info is a hint, there is no guarantee eg if you use
>> bonding and some load balancer or switch decides to send packets on
>> different links.
>>
>> Most NIC use Toeplitz hash, so given the 4-tuple, and rss key (40
>> bytes), you can actually compute the hash in software and know on which
>> RX queue traffic should land.
>>
>>
>
>
>
> --
> Andy Lutomirski
> AMA Capital Management, LLC
