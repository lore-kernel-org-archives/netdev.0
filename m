From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for traffic shapers
Date: Tue, 19 Sep 2017 17:19:18 -0700
Message-ID: <87wp4ufchl.fsf@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com> <20170918080214.yrejz67wwnp2pjzf@localhost> <87k20vip3f.fsf@intel.com> <20170919052244.77umdxuze53t6j22@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:41821 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdITATU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 20:19:20 -0400
In-Reply-To: <20170919052244.77umdxuze53t6j22@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

Richard Cochran <richardcochran@gmail.com> writes:

> On Mon, Sep 18, 2017 at 04:06:28PM -0700, Vinicius Costa Gomes wrote:
>> That's the point, the application does not need to know that, and asking
>> that would be stupid.
>
> On the contrary, this information is essential to the application.
> Probably you have never seen an actual Ethernet field bus in
> operation?  In any case, you are missing the point.
>
>> (And that's another nice point of how 802.1Qbv works, applications do
>> not need to be changed to use it, and I think we should work to achieve
>> this on the Linux side)
>
> Once you start to care about real time performance, then you need to
> consider the applications.  This is industrial control, not streaming
> your tunes from your ipod.
>
>> That being said, that only works for kinds of traffic that maps well to
>> this configuration in advance model, which is the model that the IEEE
>> (see 802.1Qcc) and the AVNU Alliance[1] are pushing for.
>
> Again, you are missing the point of what they aiming for.  I have
> looked at a number of production systems, and in each case the
> developers want total control over the transmission, in order to
> reduce latency to an absolute minimum.  Typically the data to be sent
> are available only microseconds before the transmission deadline.
>
> Consider OpenAVB on github that people are already using.  Take a look
> at simple_talker.c and explain how "applications do not need to be
> changed to use it."

Just let me use the mention of OpenAVNU as a hook to explain what we
(the team I am part of) are working to do, perhaps it will make our
choices and designs clearer.

One of the problems with OpenAVNU is that it's too coupled with the i210
NIC. One of the things we want is to decouple OpenAVNU from the
controller. The way we thought best was to propose interfaces (that
would work along side to the Linux networking stack) as close as
possible to what the current standards define, that means the IEEE
802.1Q family of specifications, in the hope that network controller
vendors would also look at the specifications when designing their
controllers.

Our objective with the Qdiscs we are proposing (both cbs and taprio) is
to provide a sane way to configure controllers that support TSN features
(we were looking specifically at the IEEE specs).

After we have some rough consensus on the interfaces to use, then we can
start working on OpenAVNU.

>
>> [1]
>> http://avnu.org/theory-of-operation-for-tsn-enabled-industrial-systems/
>
> Did you even read this?
>
>     [page 24]
>
>     As described in section 2, some industrial control systems require
>     predictable, very low latency and cycle-to-cycle variation to meet
>     hard real-time application requirements. In these systems,
>     multiple distributed controllers commonly synchronize their
>     sensor/actuator operations with other controllers by scheduling
>     these operations in time, typically using a repeating control
>     cycle.
>     ...
>     The gate control mechanism is itself a time-aware PTP application
>     operating within a bridge or end station port.
>
> It is an application, not a "god box."
>
>> In short, I see a per-packet transmission time and a per-queue schedule
>> as solutions to different problems.
>
> Well, I can agree with that.  For some non real-time applications,
> bandwidth shaping is enough, and your Qdisc idea is sufficient.  For
> the really challenging TSN targets (industrial control, automotive),
> your idea of an opaque schedule file won't fly.

(Sorry if I am being annoying here, but the idea of an opaque schedule
is not ours, that comes from the people who wrote the Qbv specification)

I have a question, what about a controller that doesn't provide a way to
set a per-packet transmission time, but it supports Qbv/Qbu. What would
be your proposal to configure it?

(I think LaunchTime is something specific to the i210, right?)


Cheers,
