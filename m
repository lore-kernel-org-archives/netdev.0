From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 23:31:23 -0500 (EST)
Message-ID: <20170221.233123.1325495796860476497.davem@davemloft.net>
References: <CALx6S36bujuFmDkvG8V5cuigbeNpJX-nprL1_1Ub+m4AiV3Lqw@mail.gmail.com>
        <20170221.223457.625029624566323414.davem@davemloft.net>
        <CALx6S36TNb38pg67_0kymYPpw-BO0DNHQkqa_AGPEZ-RHXaPgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbdBVEb1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 23:31:27 -0500
In-Reply-To: <CALx6S36TNb38pg67_0kymYPpw-BO0DNHQkqa_AGPEZ-RHXaPgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 20:02:07 -0800

> I took out the parts about allowing non-BPF hooks in the patchset as
> you requested.I believe code that is cleaner than what is currently
> there, and the fact that the API is extensible to allow other uses
> is a hallmark of good design.

For BPF only cases, there is no need for a chain of callbacks.  BPF
has tailcalls, which can be used to solve whatever problem chained
XDP stuff would be used for.

The only other possible use of chained XDP is non-BPF uses, thus my
and others's fundamental objection.

It's not a cleanup or a simplification for driver writers, you're
adding a new feature, and one whose need is not at all clear.

I also object to chaining on another level.  The whole idea of XDP
programs are that they exist in a very _precise_ and specific context
and do one thing.  If there are chains, there are dependencies, and
thus the context is variable.  We do not want this, trust me.

Is it such a huge deal to defer this chaining thing to after your
other simplifications?  All of these things you are trying to add are
blocking the less controversial and useful parts of your work.

Thanks.
