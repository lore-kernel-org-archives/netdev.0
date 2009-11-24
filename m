From: Tom Herbert <therbert@google.com>
Subject: Re: NUMA and multiQ interation
Date: Tue, 24 Nov 2009 11:51:39 -0800
Message-ID: <65634d660911241151q4d7522c0nf9c2e4667c333185@mail.gmail.com>
References: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
	 <20091124.100613.240222762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51308 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758101AbZKXTvi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 14:51:38 -0500
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id nAOJpgRi028248
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 19:51:43 GMT
Received: from pxi41 (pxi41.prod.google.com [10.243.27.41])
	by zps37.corp.google.com with ESMTP id nAOJnnUx005531
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 11:51:39 -0800
Received: by pxi41 with SMTP id 41so4121771pxi.19
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 11:51:39 -0800 (PST)
In-Reply-To: <20091124.100613.240222762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 10:06 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 24 Nov 2009 09:04:41 -0800
>
>> What is the expected interaction here, and would these results be
>> typical? =A0If so, would this warrant the need to associate each RX
>> queue to a numa node, instead of just the device?
>
> Yes we are fully aware of this and discussed it at netconf this year,=
 see
> in particular:
>
> http://vger.kernel.org/netconf2009_slides/netconf2009_numa_discussion=
=2Eodp
>
> PJ is also currently trying to pass upstream some changes such that t=
hese
> NUMA allocation bits can be exported to userspace and thus irqbalance=
d
> can pick IRQ targetting more intelligently when a driver allocates pe=
r-queue
> memory resources on different NUMA nodes. =A0The thread discussing th=
is has
> been going active for the past few days, maybe you missed it.
>

I saw that thread, and it looks compelling.  But we have applications
that are network bound such that we want to use multiple queues across
multiple nodes for scaling-- and trying keep all queues on the same
node does not scale very well.  Maybe ignoring NUMA allocation could
be a fall-back mode in a dynamic allocation with heavy load?

Tom
