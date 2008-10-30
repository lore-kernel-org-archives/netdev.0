From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 04:57:54 -0700
Message-ID: <166fe7950810300457h3b1c11c9m437aab08ddc8afa3@mail.gmail.com>
References: <20081027.123056.22851224.davem@davemloft.net>
	 <20081027.170524.124746723.davem@davemloft.net>
	 <20081030105431.GI20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:52139 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777AbYJ3L57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 07:57:59 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m9UBvvRI007694
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 04:57:57 -0700
Received: from ug-out-1314.google.com (ugfh2.prod.google.com [10.66.184.2])
	by zps36.corp.google.com with ESMTP id m9UBvslj017489
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 04:57:55 -0700
Received: by ug-out-1314.google.com with SMTP id h2so858310ugf.32
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 04:57:54 -0700 (PDT)
In-Reply-To: <20081030105431.GI20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 3:54 AM, Thomas Graf <tgraf@suug.ch> wrote:
> * David Miller <davem@davemloft.net> 2008-10-27 17:05
>> Sorry I had to revert this:
>>
>> 1) It can't work as a tristate option, the control group subsystem
>>    framework doesn't work with modular enables.
>
> Right, I'll fix this. Thank you.
>
>> 2) There was still a discussion going on about the hardirq/softirq
>>    tracing bits.  They seem unnecessary.
>
> I don't see how looking at the number of nested bh disable calls can
> be used to reliably determine if a code segment is run in softirq. The
> method fails if a dev_queue_xmit() caller running in softirq context
> doesn't disable bh explicitly but instead relies on the fact that bh
> must already have been disabled as per bh context definition.

I would like to request that the alternative for storing the class
identifier in the socket be reconsidered. It is a minor change and
would help the accounting system to be much more accurate since it
would cover these corner cases and accurately account for packets in
the interrupt context.

The complexity of migrating open sockets across cgroups can easily be
fixed if it is deemed to be a problem but is unlikely to be a big
issue for most workloads like browsers or web servers.

-Thanks,
Ranjit

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
