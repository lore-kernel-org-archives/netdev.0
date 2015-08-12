From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Wed, 12 Aug 2015 16:14:33 +0800
Message-ID: <CAOrge3pTg8qOzrNDBtNYB+UUKVmJKe-T+azrCqdrkt=T+HL0Tg@mail.gmail.com>
References: <CAOrge3qi=7YPRO+VeCDvHsm_7SFC4Y=+JpwQtwAV3zk_q4fEAw@mail.gmail.com>
 <55C1D207.3040905@iogearbox.net> <55C24BAE.7090702@gmail.com>
 <CAOrge3ps456Zw8nnnVitU3t6sEQ=Z=6QzO5Zsp4s17MhhZxyKQ@mail.gmail.com>
 <55C3B8C8.9030507@redhat.com> <CAOrge3oRWUfdMjDgH8PSY_5Y8=KKv2Cr9T3ZLXvuNx6_eq7g0Q@mail.gmail.com>
 <55C4D803.3090108@redhat.com> <878u9njaon.fsf@stressinduktion.org>
 <CAOrge3qxOb_XrspuvYjV0pDDxUUoqGE3690KUQGoxZMxuD-NRQ@mail.gmail.com>
 <CAOrge3q16PRh3TEBaGUeYDhLzWhCCytn+sopTzBr_23cj1gmaw@mail.gmail.com>
 <878u9jijuc.fsf@stressinduktion.org> <CAOrge3pSQ7eck14biTncjOyGD-DKY0DvRr7JKpS3BowoSDry-Q@mail.gmail.com>
 <87y4hjgy6p.fsf@stressinduktion.org> <55CA608B.1070302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CA608B.1070302@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2015 at 4:52 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 08/10/2015 04:50 AM, Hannes Frederic Sowa wrote:
>>
>> Hello,
>>
>> Zang MingJie <zealot0630@gmail.com> writes:
>>
>>> Here comes several options:
>>>
>>> 1. reject local next hop w/ EINVAL
>>> 2. delete route when local next hop removed
>>
>> Will also cause some people to complain.
>>
>>> 3. transition between RT_SCOPE_HOST amd RT_SCOPE_LINK
>>
>> I don't understand the scope transition. I know Alex mentioned it for
>> the first time. Maybe he can explain?
>
>
> If I am not mistaken part of the issue in terms of the behaviour being seen
> is due to the fact that the nexthop scope is recorded only when the route is
> added, and there is code in place in rt_set_nexthop which will only use the
> gateway if the scope is RT_SCOPE_LINK.  So what we would probably need to do
> is go through and audit any routes on a given interface every time an
> address is added or removed and if the nh_gw is equal to the address added
> or removed would would need to transition between RT_SCOPE_LINK and
> RT_SCOPE_HOST since the gateway is transitioning between the local system
> and somewhere on the other side of the link.
>
> The problem is that this would still be a behaviour change and there may be
> somebody that has heartburn about it.

That's why I'm going to introduce a sysconf entry, with the entry
unset, keep compatibility; with the entry set, fix the bug.

>
>>> 4. document it
>>
>> I prefer that one :)
>
>
> Yeah, me too.  The fact is things have worked this way up until now and I
> suspect the reason why this hasn't been reported until now is simply because
> in many cases it works since routes are usually updated if you are moving
> the gateway onto the local system.
>
> - Alex
