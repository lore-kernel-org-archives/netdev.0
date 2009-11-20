From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:50:03 -0800
Message-ID: <65634d660911201550v34bc463ao17dcd7b16f62264f@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120.153913.242783116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:30276 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbZKTXuC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 18:50:02 -0500
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id nAKNo6Dm023774
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 23:50:07 GMT
Received: from pwj15 (pwj15.prod.google.com [10.241.219.79])
	by wpaz1.hot.corp.google.com with ESMTP id nAKNo3lI007009
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:50:03 -0800
Received: by pwj15 with SMTP id 15so2554638pwj.23
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:50:03 -0800 (PST)
In-Reply-To: <20091120.153913.242783116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 3:39 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 20 Nov 2009 15:28:58 -0800
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Schedule NAPI for backlog device */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (napi_schedule_prep(&queue->backlog)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu !=3D smp_processor=
_id()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_set(cp=
u,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ge=
t_cpu_var(rps_remote_softirq_cpus));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __raise_so=
ftirq_irqoff(NET_RX_SOFTIRQ);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_sch=
edule(&queue->backlog);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto enqueue;
>> + =A0 =A0 }
>
> I still think, like Jared, this should occur at the end of the NAPI
> ->poll() run.
>

We only set the bit in remote_softirq_cpus in here.  The actual IPIs
are sent at the end net_rx_action.  I'm not exactly sure what you're
thinking on this...

> Otherwise show us numbers indicating that it makes a big difference.
> :-)
>
