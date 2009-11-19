From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Thu, 19 Nov 2009 08:08:31 +0000
Message-ID: <20091119080831.GA6874@ff.dom.local>
References: <65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:5625 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbZKSIIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 03:08:32 -0500
Received: by fg-out-1718.google.com with SMTP id d23so664895fga.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 00:08:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-2009 17:43, Tom Herbert wrote:
> On Mon, Nov 16, 2009 at 3:19 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue, 10 Nov 2009 22:53:17 -0800
>>
>>> +             /* Schedule NAPI for backlog device */
>>> +             if (napi_schedule_prep(&queue->backlog)) {
>>> +                     if (cpu != smp_processor_id()) {
>>> +                             cpu_set(cpu,
>>> +                                 get_cpu_var(rps_remote_softirq_cpus));
>>> +                             __raise_softirq_irqoff(NET_RPS_SOFTIRQ);
>>> +                     } else
>>> +                             __napi_schedule(&queue->backlog);
>>> +             }
>>> +             goto enqueue;
>> {,__}send_remote_softirq() doesn't work? :-)
>>
> NET_RPS_SOFTIRQ is intended to provide coalescing of IPIs.

It seems calling net_rps_action() at the end of net_rx_action() should
do (mostly) the same, at least for napi drivers. And I'm not sure it's
worth to add a new softirq because of non-napis.

Jarek P.
