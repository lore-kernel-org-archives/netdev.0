From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Wed, 05 Oct 2011 07:50:26 -0400
Message-ID: <6.2.5.6.2.20111005074401.03a9d0f8@binnacle.cx>
References: <6.2.5.6.2.20111005025227.03a9d9f0@binnacle.cx>
 <1317804832.2473.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1317804832.2473.25.camel@edumazet-HP-Compaq-6005-Pr
 o-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Joe Perches <joe@perches.com>, Christoph Lameter <cl@gentwo.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>,
	Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317804832.2473.25.camel@edumazet-HP-Compaq-6005-Pr
 o-SFF-PC>
References: <6.2.5.6.2.20111005025227.03a9d9f0@binnacle.cx>
 <1317804832.2473.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 10:53 AM 10/5/2011 +0200, Eric Dumazet wrote:
>
>Note :
>
>Your results are from a combination of a user
>application and kernel default strategies.
>
>On other combinations, results can be completely different.
>
>A wakeup strategy is somewhat tricky : 
>
>- Should we affine or not.
>- Should we queue the wakeup on a remote CPU,
>  to keep scheduler data hot in a single cpu cache.
>- Should we use RPS/RFS to queue the packet to
>  another CPU before  even handling it in our stack,
>  to keep network data hot in a single cpu
>   cache. (check Documentation/networking/scaling.txt)
>
>At least, with recent kernels, we have many
>available choices to tune a workload.

I would argue that results speak louder than
features.  A 300% deterioration in latency,
600% deterioration in sigma latency and
a 50-100% increase in apparent system overhead
is not impressive.

Our application is designed to run optimally
as a scalable real-time network transaction
processor and provides for a variety of
different thread-pool and queuing approaches.
Performance is worse for every one of them
in newer kernels.  The ones that scale the
best fared worst.

It seems to me that any scheduler-intensive
application will suffer a similar fate.
