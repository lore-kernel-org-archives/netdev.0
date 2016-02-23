From: Meelis Roos <mroos@linux.ee>
Subject: Re: Invalid sk_policy[] access (was Re: Recent spontaneous reboots
 on multiple machines)
Date: Tue, 23 Feb 2016 21:36:24 +0200 (EET)
Message-ID: <alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
References: <alpine.LRH.2.20.1601061716510.27880@math.ut.ee> <alpine.LRH.2.20.1601061722190.27880@math.ut.ee> <20160107174105.GD23579@oracle.com> <alpine.LRH.2.20.1601072133480.29795@math.ut.ee> <20160107201445.GF23579@oracle.com> <20160108172022.GA3398@oracle.com>
 <alpine.LRH.2.20.1602051103140.5582@math.ut.ee> <20160214105131.GD20715@oracle.com> <alpine.LRH.2.20.1602150751180.29662@math.ut.ee> <20160222010201.GB23053@oracle.com> <20160223121244.GI28756@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: sparclinux@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20160223121244.GI28756@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I figured out what's the root-cause of my panics.

Great!

>   sizeof             32-bit        64-bit
> -------------------------------------------
> request_sock          256           312
> inet_request_sock     272           328
> sock                  688          1216
> 
> And offsetof sk_policy[1] is 256 on the 32-bit v440, whereas
> it is 520 on my 64-bit T5. 

Sorry, I do not understand - what is 32-bit on V440? The kernel should 
be 64-bit since it's sun4u.

> so how is this supposed to work? (Evidently it worked for Meelis
> before, but I dont know if that was before or after  commit
> 9e17f8a475).

It might be related to my problem, yes (I have different kernel configs 
on different machines and the XFRM settings are varying at least). 

However, I have not succeeded in reproducing the problem at will - git 
checkout of another release + subsequent compile still does not trigger 
it. But if it is the same problem, it seems to go int triple fault or 
something similar for me to cause it reboot with no trace in the 
console.

-- 
Meelis Roos (mroos@linux.ee)
