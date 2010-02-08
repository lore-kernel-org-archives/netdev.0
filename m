From: Tom Herbert <therbert@google.com>
Subject: Re: rps: question
Date: Sun, 7 Feb 2010 21:58:32 -0800
Message-ID: <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:16091 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab0BHF6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 00:58:36 -0500
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o185wX1X012560
	for <netdev@vger.kernel.org>; Mon, 8 Feb 2010 05:58:34 GMT
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz24.hot.corp.google.com with ESMTP id o185wWTo000913
	for <netdev@vger.kernel.org>; Sun, 7 Feb 2010 21:58:32 -0800
Received: by pzk12 with SMTP id 12so1092720pzk.13
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2010 21:58:32 -0800 (PST)
In-Reply-To: <1265568122.3688.36.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 7, 2010 at 10:42 AM, jamal <hadi@cyberus.ca> wrote:
>
> Hi Tom,
>
> First off: Kudos on the numbers you are seeing; they are
> impressive. Do you have any numbers on a forwarding path test?
>
I don't have specific numbers, although we are using this on
application doing forwarding and numbers seem in line with what we see
for an end host.

> My first impression when i saw the numbers was one of suprise.
> Back in the days when we tried to split stack processing the way
> you did(it was one of the experiments on early NAPI), IPIs were
> _damn_ expensive. What changed in current architecture that makes
> this more palatable? IPIs are still synchronous AFAIK (and the more
> IPI receiver there are, the worse the ACK latency). Did you test this
> across other archs or say 3-4 year old machines?
>

No, the cost of the IPIs hasn't been an issue for us performance-wise.
 We are using them extensively-- up to one per core per device
interrupt.

We're calling __smp_call_function_single which is asynchronous in that
the caller provides the call structure and there is not waiting for
the IPI to complete.  A flag is used with each call structure that is
set when the IPI is in progress, this prevents simultaneous use of a
call structure.

I haven't seen any architectural specific issues with the IPIs, I
believe they are completing in < 2 usecs on platforms we're running
(some opteron systems that are over 3yrs old).

Tom

> cheers,
> jamal
>
