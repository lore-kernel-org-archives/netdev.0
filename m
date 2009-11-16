From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Mon, 16 Nov 2009 08:43:05 -0800
Message-ID: <65634d660911160843j3df398f2w876044083181cfcd@mail.gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	 <20091116.031914.65020185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:21847 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbZKPQnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 11:43:07 -0500
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id nAGGh8Bb015048
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 16:43:09 GMT
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by zps36.corp.google.com with ESMTP id nAGGgXVX015636
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 08:43:06 -0800
Received: by pzk11 with SMTP id 11so3519613pzk.14
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 08:43:05 -0800 (PST)
In-Reply-To: <20091116.031914.65020185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 3:19 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 10 Nov 2009 22:53:17 -0800
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
ftirq_irqoff(NET_RPS_SOFTIRQ);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_sch=
edule(&queue->backlog);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto enqueue;
>
> {,__}send_remote_softirq() doesn't work? :-)
>
NET_RPS_SOFTIRQ is intended to provide coalescing of IPIs.

send_remote_softirq could be used, but we would also need to get the
napi structure on the remote cpu poll list so that would probably need
to be protected by locks (something like __napi_schedule_oncpu could
be defined).  Would this be better to do?
