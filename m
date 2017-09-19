From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Tue, 19 Sep 2017 07:22:44 +0200
Message-ID: <20170919052244.77umdxuze53t6j22@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
 <87k20vip3f.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:48719 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdISFWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 01:22:50 -0400
Received: by mail-wr0-f171.google.com with SMTP id 108so2048455wra.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 22:22:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87k20vip3f.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 04:06:28PM -0700, Vinicius Costa Gomes wrote:
> That's the point, the application does not need to know that, and asking
> that would be stupid.

On the contrary, this information is essential to the application.
Probably you have never seen an actual Ethernet field bus in
operation?  In any case, you are missing the point.

> (And that's another nice point of how 802.1Qbv works, applications do
> not need to be changed to use it, and I think we should work to achieve
> this on the Linux side)

Once you start to care about real time performance, then you need to
consider the applications.  This is industrial control, not streaming
your tunes from your ipod.
 
> That being said, that only works for kinds of traffic that maps well to
> this configuration in advance model, which is the model that the IEEE
> (see 802.1Qcc) and the AVNU Alliance[1] are pushing for.

Again, you are missing the point of what they aiming for.  I have
looked at a number of production systems, and in each case the
developers want total control over the transmission, in order to
reduce latency to an absolute minimum.  Typically the data to be sent
are available only microseconds before the transmission deadline.

Consider OpenAVB on github that people are already using.  Take a look
at simple_talker.c and explain how "applications do not need to be
changed to use it."

> [1]
> http://avnu.org/theory-of-operation-for-tsn-enabled-industrial-systems/

Did you even read this?

    [page 24]

    As described in section 2, some industrial control systems require
    predictable, very low latency and cycle-to-cycle variation to meet
    hard real-time application requirements. In these systems,
    multiple distributed controllers commonly synchronize their
    sensor/actuator operations with other controllers by scheduling
    these operations in time, typically using a repeating control
    cycle.
    ...
    The gate control mechanism is itself a time-aware PTP application
    operating within a bridge or end station port.

It is an application, not a "god box."

> In short, I see a per-packet transmission time and a per-queue schedule
> as solutions to different problems.

Well, I can agree with that.  For some non real-time applications,
bandwidth shaping is enough, and your Qdisc idea is sufficient.  For
the really challenging TSN targets (industrial control, automotive),
your idea of an opaque schedule file won't fly.

Thanks,
Richard
