From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Linux 3.1-rc9
Date: Wed, 02 Nov 2011 20:15:51 -0400
Message-ID: <1320279351.4793.60.camel@gandalf.stny.rr.com>
References: <alpine.LFD.2.02.1110172237030.3240@ionos>
	 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
	 <20111018182046.GF1309@hostway.ca>
	 <alpine.LFD.2.02.1110182146440.3240@ionos>
	 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
	 <20111031173246.GA10614@hostway.ca>
	 <20111102221023.GA27457@home.goodmis.org>
	 <20111102230009.GB27457@home.goodmis.org>
	 <20111103000941.GJ5971@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111103000941.GJ5971@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-02 at 17:09 -0700, Simon Kirby wrote:
>  
> [   49.032008] other info that might help us debug this:
> [   49.032008] 
> [   49.032008]  Possible unsafe locking scenario:
> [   49.032008] 
> [   49.032008]        CPU0                    CPU1
> [   49.032008]        ----                    ----
> [   49.032008]   lock(slock-AF_INET);
> [   49.039565]                                lock(slock-AF_INET/1);
> [   49.039565]                                lock(slock-AF_INET);
> [   49.039565]   lock(slock-AF_INET/1);
> [   49.039565] 
> [   49.039565]  *** DEADLOCK ***
> [   49.039565] 

> Did that help? I'm not sure if that's what you wanted to see...


Yes, this looks much better than what you previously showed. The added
"/1" makes a world of difference.

Thanks!

I'll add your "Tested-by". Seems rather strange as we didn't fix the bug
you are chasing, but instead fixed the output of what the bug
produced ;)

-- Steve
