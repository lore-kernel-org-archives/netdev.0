From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 17:09:22 -0700
Message-ID: <1e41a3230903091709i740d95ddhefc1df2c71ea60b6@mail.gmail.com>
References: <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	 <20090309195906.M50328@bts.sk>
	 <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
	 <20090309.165205.11054081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: md@bts.sk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:20979 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbZCJAJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 20:09:25 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1253026yxm.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 17:09:23 -0700 (PDT)
In-Reply-To: <20090309.165205.11054081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 4:52 PM, David Miller <davem@davemloft.net> wrote:
> From: John Heffner <johnwheffner@gmail.com>
> Date: Mon, 9 Mar 2009 13:23:15 -0700
>
>> A drop-tail queue size of 1000 packets on a local interface is
>> questionable, and I think this is the real source of your problem.
>
> Are you suggested we decrease it? :-)

I am not so bold. :-D  (And note the drop-tail prefix.)

A long queue with AQM would probably be best, but would require
careful testing before enabling by default.  It would almost certainly
cause pain for some.

And, for the vast majority of people for whom the local interface is
not the bottleneck, it makes no difference.  It hurts worst for
someone doing bulk transfer with a GigE device in 100 Mbps (or worse,
10-Mbps) mode, where 1000 pkts is a long time, while simultaneously
doing something latency-sensitive.  I suspect this is the case Marian
is experiencing.

  -John
