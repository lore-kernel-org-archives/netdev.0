From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC,PATCH] mutex: mutex_is_owner() helper
Date: Wed, 4 Nov 2009 16:40:15 +0100
Message-ID: <20091104154015.GA32567@elte.hu>
References: <4AF19D06.3060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756281AbZKDPkS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF19D06.3060401@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> mutex_is_locked() is called most of the time to check if mutex is locked by current
> thread. But it's a lazy check, because mutex might be locked by another thread.
> 
> Adds a new mutex_is_owned_by() helper, that can check ownership if CONFIG_SMP or
> CONFIG_DEBUG_MUTEXES are set.
> 
> Returns are 
>  0 if mutex is unlocked.
>  1 if locked
> -1 if not locked by designated thread.
> 
> Last return value is possible only if CONFIG_SMP=y or CONFIG_DEBUG_MUTEXES=y
> 
> Example of use :
> 
> int rtnl_is_locked(void)
> {
> 	return mutex_is_locked(&rtnl_mutex);
> }
> ->
> int rtnl_is_locked(void)
> {
> 	return mutex_is_owned_by(&rtnl_mutex, current_thread_info()) == 1;
> }

To make sure this does not extend mutexes to be used a recursive 
mutexes, mind naming it more clearly, like debug_mutex_is_owned(), and 
adding a comment that says that this shouldnt be taken?

Also, it's somewhat imprecise: on !SMP && !DEBUG_MUTEXES we might return 
a false '1'. Which happens to work for the rtnl usecase - but might not 
in other cases.

	Ingo
