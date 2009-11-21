From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 16:12:00 -0800
Message-ID: <65634d660911201612y12a9b5bnb6685da040ad832d@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120.153913.242783116.davem@davemloft.net>
	 <65634d660911201550v34bc463ao17dcd7b16f62264f@mail.gmail.com>
	 <20091120.160507.110482370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36037 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbZKUAL7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 19:11:59 -0500
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id nAL0C3Ww020426
	for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 00:12:04 GMT
Received: from pxi35 (pxi35.prod.google.com [10.243.27.35])
	by zps19.corp.google.com with ESMTP id nAL0C1ro010010
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 16:12:01 -0800
Received: by pxi35 with SMTP id 35so627322pxi.18
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 16:12:01 -0800 (PST)
In-Reply-To: <20091120.160507.110482370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I guess my confusion is from the:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__rais=
e_softirq_irqoff(NET_RX_SOFTIRQ);
>
> you are doing as you set the cpus in rps_remote_softirq_cpus.
>
> Why do you need to schedule the local RX softirq, when we know we're
> in a NAPI poll loop and thus that we're in a softirq, and thus that w=
e
> will fire off the IPIs at the end of net_rx_action()?
>
> That's what you're doing, the softirq raising just seems superfluous.
>

Ah, right. If RPS can't be used non-NAPI case, this line is now
superfluous.  It can be removed.

Thanks
