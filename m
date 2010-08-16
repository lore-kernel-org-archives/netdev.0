From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 20:36:54 +0200
Message-ID: <1281983814.1926.1763.camel@laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281982566.3268.137.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-16 at 14:16 -0400, Steven Rostedt wrote:
> @@ -729,8 +729,10 @@  static void get_counters(const struct
> xt_table_info *t,
>         local_bh_enable();
>         /* Processing counters from other cpus, we can let bottom half
> enabled,
>          * (preemption is disabled)
> +        * We must turn off lockdep to avoid a false positive.
>          */
>  
> +       lockdep_off();
>         for_each_possible_cpu(cpu) {
> 
nack!
