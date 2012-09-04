From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC v2] fq_codel : interval servo on hosts
Date: Tue, 4 Sep 2012 09:40:40 -0700
Message-ID: <CAA93jw6k4pgwanTa81oHb8jV6WGMfoo6KuOBSjbrfU3eRMbt5A@mail.gmail.com>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
	<1346421466.2591.38.camel@edumazet-glaptop>
	<CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
	<1346503884.7996.65.camel@edumazet-glaptop>
	<CAB_+Fg5xPRqEZNdH0mYogmm4LitMvycSLB-X1_7ryn4RY9FvSA@mail.gmail.com>
	<1346772855.13121.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, codel@lists.bufferbloat.net,
	Kathleen Nichols <nichols@pollere.com>,
	netdev <netdev@vger.kernel.org>, Tomas Hruby <thruby@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55969 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415Ab2IDQkm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 12:40:42 -0400
Received: by wgbdr13 with SMTP id dr13so5855286wgb.1
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 09:40:41 -0700 (PDT)
In-Reply-To: <1346772855.13121.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 4, 2012 at 8:34 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Tue, 2012-09-04 at 08:10 -0700, Nandita Dukkipati wrote:
>> The idea of using srtt as interval makes sense to me if alongside we
>> also hash flows with similar RTTs into same bucket. But with just th=
e
>> change in interval, I am not sure how codel is expected to behave.
>>
>> My understanding is: the interval (usually set to worst case expecte=
d
>> RTT) is used to measure the standing queue or the "bad" queue. Suppo=
se
>> 1ms and 100ms RTT flows get hashed to same bucket, then the interval
>> with this patch will flip flop between 1ms and 100ms. How is this
>> expected to measure a standing queue? In fact I think the 1ms flow m=
ay
>> land up measuring the burstiness or the "good" queue created by the
>> long RTT flows, and this isn't desirable.

Experiments would be good.

>
> Well, how things settle with a pure codel, mixing flows of very
> different RTT then ?

Elephants are shot statistically more often than mice.

> It seems there is a high resistance on SFQ/fq_codel model because of =
the
> probabilities of flows sharing a bucket.

I was going to do this in a separate email, because it is a little off-=
topic.

fq_codel has a standing queue problem, based on the fact that when a
queue empties, codel.h resets. This made sense for the single FIFO
codel but not multi-queued fq_codel. So after we hit X high rate
flows, target can never be achieved, even straining mightily, and we
end up with a standing queue again.

Easily seen with like 150 bidirectional flows at 10 or 100Mbit.

(as queues go, it's still pretty good queue. And: I've fiddled with
various means of draining multi-queue behavior thus far, and they
ended up unstable/unfair)

> So what about removing the stochastic thing and switch to a hash with
> collision resolution ?

Was considered and discarded in the original SFQ paper as being too
computationally intensive
(in 1993). Worth revisiting.

http://www2.rdrop.com/~paulmck/scalability/paper/sfq.2002.06.04.pdf

>
>



--=20
Dave T=E4ht
http://www.bufferbloat.net/projects/cerowrt/wiki - "3.3.8-17 is out
with fq_codel!"
