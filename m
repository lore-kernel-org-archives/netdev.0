From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 09:40:32 +1200
Message-ID: <5640c7e00607201440v38911f9ble6dbee9f6725be99@mail.gmail.com>
References: <20060719131915.GA21942@ms2.inr.ac.ru>
	 <20060720073223.GA15567@tservice.net.ru>
	 <20060720164100.GA9213@ms2.inr.ac.ru>
	 <20060720210849.GA28715@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:26660 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1030383AbWGTVke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 17:40:34 -0400
Received: by nf-out-f131.google.com with SMTP id k65so28774nfa
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2006 14:40:33 -0700 (PDT)
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060720210849.GA28715@tservice.net.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> If we consider netchannels as how Van Jackobson discribed them, then
> mutext is not needed, since it is impossible to have several readers or
> writers. But in socket case even if there is only one userspace
> consumer, that lock must be held to protect against bh (or introduce
> several queues and complicate a lot their's management (ucopy for
> example)).
>
As I recall Van's talk you don't need a lock with a ring buffer if you
have a start and end variable pointing to location within ring buffer.

He didn't explain this in great depth as it is computer science 101
but here is how I would explain it:

Once socket is initialiased consumer is the only one that sets start
variable and network driver reads this only. It is the other way
around for the end variable. As long as the writes are atomic then you
are fine. You only need one ring buffer in this scenario and two
atomic variables.

Having atomic writes does have overhead but far less than locking semantic.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
