From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Tue, 24 May 2011 23:06:09 -0700
Message-ID: <20110525060609.GA32244@dev1756.snc6.facebook.com>
References: <201104250033.03401.maxi@daemonizer.de>
 <1303878240.2699.41.camel@edumazet-laptop>
 <1303878771.2699.44.camel@edumazet-laptop>
 <201104271352.00601.maxi@daemonizer.de>
 <20110512211033.GA3468@dev1756.snc6.facebook.com>
 <1305234953.2831.2.camel@edumazet-laptop>
 <20110524213327.GA3917@dev1756.snc6.facebook.com>
 <1306291469.3305.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun Sharma <asharma@fb.com>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306291469.3305.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 04:44:29AM +0200, Eric Dumazet wrote:
> 
> Hmm, thanks for the report. Are you running x86 or another arch ?
> 

This was on x86.

> We probably need some sort of memory barrier.
> 
> However, locking this central lock makes the thing too slow, I'll try to
> use an atomic_inc_return on p->refcnt instead. (and then lock
> unused_peers.lock if we got a 0->1 transition)

Another possibility is to do the list_empty() check twice. Once without
taking the lock and again with the spinlock held.

 -Arun
