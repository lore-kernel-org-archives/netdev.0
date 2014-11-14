From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 14:27:45 -0800
Message-ID: <CALCETrWhsj+byMeT=WHb9eLR_vgsUe58Li8JDLaTvsSPWp1DKQ@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
 <CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
 <1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
 <CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
 <CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
 <CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
 <CA+mtBx9dSNOD5Z8GinU8F1mj_PgU0sTC5g8S9vRuSnSUzAoD=g@mail.gmail.com>
 <CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw@mail.gmail.com> <1416003883.17262.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416003883.17262.72.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 2:24 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, 2014-11-14 at 14:10 -0800, Andy Lutomirski wrote:
>
>> I have a bunch of threads that are pinned to various CPUs or groups of
>> CPUs.  Each thread is responsible for a fixed set of flows.  I'd like
>> those flows to go to those CPUs.
>>
>> RFS will eventually do it, but it would be nice if I could
>> deterministically ask for a flow to be routed to the right CPU.  Also,
>> if my thread bounces temporarily to another CPU, I don't really need
>> the flow to follow it -- I'd like it to stay put.
>>
>> This has a significant benefit over using automatic steering: with
>> automatic steering, I have to make all of the hash tables have a size
>> around the square of the total number of the flows in order to make it
>> reliable.
>>
>> Something like SO_STEER_TO_THIS_CPU would be fine, as long as it
>> reported whether it worked (for my diagnostics).
>
> This requires some kind of hardware support, and unfortunately this is
> not generic.
>
> With SO_INCOMING_CPU, you simply can pass fd of sockets around threads,
> so that a dumb RSS multiqueue NIC is OK (assuming you are not using some
> encapsulation that NIC is not able to parse to find L4 information)

I can't really do this.  It means that the performance of my system
will be wildly different every time I restart it.  I don't have enough
connections for everything to average out.

>
> Steering is a dream, I really think its easier to build flows so that
> their RX queue matches your requirements.

I have supporting hardware :)  I just want it to work without
programming the ntuple table myself.

>
> We usually can pick at least one element of the 4-tuple, so its actually
> possible to get this before connect().
>

Hmm.  An API for that would be quite nice :)

>
> Two cases :
>
> 1) Passive connections.
>
>    After accept(), get SO_INCOMING_CPU, then pass the fd to appropriate
> thread of your pool.
>
> 2) Active connections .
>    find a proper 4-tuple, bind() then connect(). Eventually check
> SO_INCOMING_CPU to verify your expectations.

The people at the other end will be really pissed if that results in
lots of reconnections.

--Andy

>
>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
