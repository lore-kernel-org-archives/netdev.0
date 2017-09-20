From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Tue, 19 Sep 2017 17:48:19 -0700
Message-ID: <CALx6S35wbwhz7COqGuUgJZcd8TwYcaVOHpxZxTOd4TuQX76Crg@mail.gmail.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
 <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
 <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
 <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com> <1505231262.15310.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <ef594f90-0f76-bdf5-63ce-e8750ee0d60f@intel.com> <CALx6S372oQ4OsyMd66zwQ08pMvPvLj7Ejf=Cv24xDkdtVXaYjA@mail.gmail.com>
 <9b247caf-fde0-1e39-aa94-f7b3bc4fc88a@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:37443 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbdITAsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 20:48:21 -0400
Received: by mail-qk0-f194.google.com with SMTP id r66so796185qke.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 17:48:20 -0700 (PDT)
In-Reply-To: <9b247caf-fde0-1e39-aa94-f7b3bc4fc88a@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 5:34 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 9/12/2017 3:53 PM, Tom Herbert wrote:
>>
>> On Tue, Sep 12, 2017 at 3:31 PM, Samudrala, Sridhar
>> <sridhar.samudrala@intel.com> wrote:
>>>
>>>
>>> On 9/12/2017 8:47 AM, Eric Dumazet wrote:
>>>>
>>>> On Mon, 2017-09-11 at 23:27 -0700, Samudrala, Sridhar wrote:
>>>>>
>>>>> On 9/11/2017 8:53 PM, Eric Dumazet wrote:
>>>>>>
>>>>>> On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:
>>>>>>
>>>>>>> Two ints in sock_common for this purpose is quite expensive and the
>>>>>>> use case for this is limited-- even if a RX->TX queue mapping were
>>>>>>> introduced to eliminate the queue pair assumption this still won't
>>>>>>> help if the receive and transmit interfaces are different for the
>>>>>>> connection. I think we really need to see some very compelling
>>>>>>> results
>>>>>>> to be able to justify this.
>>>>>
>>>>> Will try to collect and post some perf data with symmetric queue
>>>>> configuration.
>
>
> Here is some performance data i collected with memcached workload over
> ixgbe 10Gb NIC with mcblaster benchmark.
> ixgbe is configured with 16 queues and rx-usecs is set to 1000 for a very
> low
> interrupt rate.
>       ethtool -L p1p1 combined 16
>       ethtool -C p1p1 rx-usecs 1000
> and busy poll is set to 1000usecs
>       sysctl net.core.busy_poll = 1000
>
> 16 threads  800K requests/sec
> =============================
>                   rtt(min/avg/max)usecs     intr/sec contextswitch/sec
> -----------------------------------------------------------------------
> Default                2/182/10641            23391 61163
> Symmetric Queues       2/50/6311              20457 32843
>
> 32 threads  800K requests/sec
> =============================
>                  rtt(min/avg/max)usecs     intr/sec contextswitch/sec
> ------------------------------------------------------------------------
> Default                2/162/6390            32168 69450
> Symmetric Queues        2/50/3853            35044 35847
>
No idea what "Default" configuration is. Please report how xps_cpus is
being set, how many RSS queues there are, and what the mapping is
between RSS queues and CPUs and shared caches. Also, whether and
threads are pinned.

Thanks,
Tom
