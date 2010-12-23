From: Martin Sustrik <sustrik@250bpm.com>
Subject: Re: Workqueues vs. kernel threads for processing asynchronous socket
 events
Date: Thu, 23 Dec 2010 18:54:36 +0100
Message-ID: <4D138CDC.3000504@250bpm.com>
References: <20101210152754.GC28580@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Martin Lucina <mato@kotelna.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:40435 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab0LWRyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 12:54:35 -0500
In-Reply-To: <20101210152754.GC28580@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2010 04:27 PM, Martin Lucina wrote:

> I'm trying to find the best mechanism to process events from kernel space
> sockets in an asynchronous manner. The work in progress code I have at the
> moment tries to at least call kernel_accept() on a bound TCP socket when it
> gets called by the underlying sk->sk_data_ready callback.
>
> The current approach I have is to use a workqueue and try to schedule work
> inside the callback, but this has the kernel complaining about "scheduling
> while atomic", so it doesn't look like it's the right approach? Am I
> allowed to call schedule_work() from the context of a sk->sk_data_ready
> callback or not?

It turns out that the issue was caused by kmalloc(GFP_KERNEL) in the 
callback function, not the schedule_work() function. Using GFP_ATOMIC 
instead solves the problem.

Sorry for the annoyance.
Martin
