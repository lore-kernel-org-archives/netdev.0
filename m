From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 8 Apr 2009 21:40:28 -0700
Message-ID: <65634d660904082140k727720c5o22f203aa092727a6@mail.gmail.com>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	 <20090408.173607.177460759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:25206 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759719AbZDIEkf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 00:40:35 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n394eVeV018451
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 05:40:31 +0100
Received: from qyk14 (qyk14.prod.google.com [10.241.83.142])
	by zps36.corp.google.com with ESMTP id n394eTXa013048
	for <netdev@vger.kernel.org>; Wed, 8 Apr 2009 21:40:29 -0700
Received: by qyk14 with SMTP id 14so787632qyk.14
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 21:40:29 -0700 (PDT)
In-Reply-To: <20090408.173607.177460759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 8, 2009 at 5:36 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 8 Apr 2009 15:48:12 -0700
>
>> +#ifdef CONFIG_NET_SOFTRPS
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_cpu;
>> + =A0 =A0 struct list_head =A0 =A0 =A0 =A0rps_poll_list;
>> + =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0rps_poll_list_lock;
>> + =A0 =A0 struct call_single_data rps_csd;
>> + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 rps_flags;
>> +#define RPS_SOFTIRQ_PENDING =A00x1
>> +#define RPS_SOFTIRQ_COMPLETING =A0 =A0 =A0 0x2
>> +#endif
>
> Have you seen my patch that does this with remote softirqs?
> Then you don't need a lock for the list, it can be lockless
> since only the local processor ever accesses the list.
>
> In fact, it kills the per-cpu backlog completely, everything
> takes the netif_receive_skb() path and shoots the packet to
> the remote cpu.
>
> Here is that patch, for reference. =A0It won't apply to anything
> recent but all the ideas are there.
>

Thanks for the reference to that patch, are you planning to apply it?
