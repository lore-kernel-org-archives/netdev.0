From: Michael Ma <make0818@gmail.com>
Subject: Re: qdisc spin lock
Date: Thu, 31 Mar 2016 16:48:43 -0700
Message-ID: <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	<CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33389 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbcCaXso convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:48:44 -0400
Received: by mail-io0-f172.google.com with SMTP id a129so125053376ioe.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 16:48:44 -0700 (PDT)
In-Reply-To: <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't really know that multiple qdiscs can be isolated using MQ so
that each txq can be associated with a particular qdisc. Also we don't
really have multiple interfaces...

With this MQ solution we'll still need to assign transmit queues to
different classes by doing some math on the bandwidth limit if I
understand correctly, which seems to be less convenient compared with
a solution purely within HTB.

I assume that with this solution I can still share qdisc among
multiple transmit queues - please let me know if this is not the case.

2016-03-31 15:16 GMT-07:00 Cong Wang <xiyou.wangcong@gmail.com>:
> On Wed, Mar 30, 2016 at 12:20 AM, Michael Ma <make0818@gmail.com> wro=
te:
>> As far as I understand the design of TC is to simplify locking schem=
a
>> and minimize the work in __qdisc_run so that throughput won=E2=80=99=
t be
>> affected, especially with large packets. However if the scenario is
>> that multiple classes in the queueing discipline only have the shapi=
ng
>> limit, there isn=E2=80=99t really a necessary correlation between di=
fferent
>> classes. The only synchronization point should be when the packet is
>> dequeued from the qdisc queue and enqueued to the transmit queue of
>> the device. My question is =E2=80=93 is it worth investing on avoidi=
ng the
>> locking contention by partitioning the queue/lock so that this
>> scenario is addressed with relatively smaller latency?
>
> If your HTB classes don't share bandwidth, why do you still make them
> under the same hierarchy? IOW, you can just isolate them either with =
some
> other qdisc or just separated interfaces.
