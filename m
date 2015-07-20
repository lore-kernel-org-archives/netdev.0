From: subashab@codeaurora.org
Subject: Re: [PATCH net-next] inet: Always increment refcount in
 inet_twsk_schedule
Date: Mon, 20 Jul 2015 19:14:35 -0000
Message-ID: <99d6ce13c5da5ea403b3df747d770d54.squirrel@www.codeaurora.org>
References: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
    <1437295872.1026.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54715 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbGTTOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:14:36 -0400
In-Reply-To: <1437295872.1026.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> //Initialize time wait socket and setup timer
>> inet_twsk_alloc() tw_refcnt = 0
>> __inet_twsk_hashdance() tw_refcnt = 3
>> inet_twsk_schedule() tw_refcnt = 4
>> inet_twsk_put() tw_refcnt = 3
>>
>> //Receive packet 1 in timewait state
>> tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 3 (no
>> change)
>
> This is obviously wrong.
>
> If a timewait socket is found, do we increment its refcnt before
> proceeding.
We do not increment refcount currently when we find a timewait socket.

> I've received some private mails about tw issues, that turned to be
> caused by buggy drivers or buggy arch specific code.
>
> Are you crashed observed on x86 ?
>
This is observed on ARM devices. In the current debug, all time wait
socket refcount changes were happening in TCP stack only and there was no
platform / driver code involved.

According to my understanding, we would need to increment the time wait
socket refcount first before proceeding with any subsequent operations.
However, I request your expert opinion on this.
