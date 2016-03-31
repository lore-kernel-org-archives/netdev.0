From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: qdisc spin lock
Date: Thu, 31 Mar 2016 15:16:22 -0700
Message-ID: <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33192 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757665AbcCaWQX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 18:16:23 -0400
Received: by mail-yw0-f177.google.com with SMTP id h65so117184606ywe.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 15:16:22 -0700 (PDT)
In-Reply-To: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 12:20 AM, Michael Ma <make0818@gmail.com> wrote=
:
> As far as I understand the design of TC is to simplify locking schema
> and minimize the work in __qdisc_run so that throughput won=E2=80=99t=
 be
> affected, especially with large packets. However if the scenario is
> that multiple classes in the queueing discipline only have the shapin=
g
> limit, there isn=E2=80=99t really a necessary correlation between dif=
ferent
> classes. The only synchronization point should be when the packet is
> dequeued from the qdisc queue and enqueued to the transmit queue of
> the device. My question is =E2=80=93 is it worth investing on avoidin=
g the
> locking contention by partitioning the queue/lock so that this
> scenario is addressed with relatively smaller latency?

If your HTB classes don't share bandwidth, why do you still make them
under the same hierarchy? IOW, you can just isolate them either with so=
me
other qdisc or just separated interfaces.
