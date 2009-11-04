From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 5 Nov 2009 01:04:09 +0200
Message-ID: <200911050104.09538.opurdila@ixiacom.com>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:18387 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754954AbZKDXHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 18:07:05 -0500
In-Reply-To: <4AF1F273.5020207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 November 2009 23:30:27 you wrote:

> I knew someone would do this kind of patch one day, I tried it one year ago
>  :)
> 

And I knew you would give us feedback, thanks ! You are unstoppable lately, 
how many of are out there? :) 

> First of all, you are mixing several things in this patch.
> 
> Dont do this, its not possible for us to correctly review such complex
>  patch.
> 
> Then, your patch is not based on net-next-2.6, and you really need to work
>  on this tree.
> 

Yes, the patch is not in any shape for review, we just wanted some early 
feedback on the approach itself, and I've noticed its more likely to get 
feedback when code is posted.

> Then, if you had worked on net-next-2.6, you whould have noticed UDP hash
>  tables are now dynamically sized at boot.
> An admin can even force a 65536 slots hash table for heavy duty UDP
>  servers.
> 
> Then, last point : Say I have a machine with 65000 udp sockets bound to a
>  different port, and a 65536 slots hash table, (sane values in fact, in
>  order to have best performances), then your two phase lookup will be
>  slower than the one-phase current lookup (two cache misses instead of one)
> 
> So your patch seems to solve a pathological case (where many udp sockets
>  are bounded to a particular port, but on many different IPs), and slow
>  down 99% of other uses.
> 

Very true, the benchmark itself shows a significant overhead increase on the TX 
side and indeed this case is not very common. But for us its an important 
usecase. 

Maybe there is a more clever way of fixing this specific use-case without 
hurting the common case?

Also, are there any other folks out there who would benefit by fixing this 
corner case?

Thanks,
tavi
