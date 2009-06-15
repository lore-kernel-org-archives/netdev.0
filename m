From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 15 Jun 2009 09:39:20 -0700
Message-ID: <65634d660906150939w7a940eegbe74aea7bfbb7f71@mail.gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	 <20090610.012342.121254416.davem@davemloft.net>
	 <65634d660906142252y6f7fc021l844b172995c10044@mail.gmail.com>
	 <20090615.020240.84385988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:48985 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbZFOQjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 12:39:22 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n5FGdMnJ001634
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 17:39:23 +0100
Received: from qyk3 (qyk3.prod.google.com [10.241.83.131])
	by zps38.corp.google.com with ESMTP id n5FGcquN005217
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 09:39:20 -0700
Received: by qyk3 with SMTP id 3so4983529qyk.3
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 09:39:20 -0700 (PDT)
In-Reply-To: <20090615.020240.84385988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 2:02 AM, David Miller<davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 14 Jun 2009 22:52:13 -0700
>
>>> Just to keep this topic alive, I want to mention two things:
>>>
>>> 1) Just the other day support for the IXGBE "Flow Director" was
>>>   added to net-next-2.6, it basically does flow steering in
>>>   hardware.  It remembers where the last TX for a flow was
>>>   made, and steers RX traffic there.
>>>
>>
>> That's very cool.  Is this able to preserve in order delivery?
>
> I don't know how the hardware works to this level of detail,
> sorry.  But yet that's a very important issue.
>
>> What is the advantage over using a shared skbuff queue and making
>> doing a single IPI to schedule the backlog device on the remote CPU?
>
> No locking.  Queue is only ever accessed by the local cpu.
>

There's no lock to put the call_single_data structures onto remote
CPU's list?  Looking at generic_exec_single...
