From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add
 percpu_counter_mod_bh
Date: Tue, 7 Mar 2006 18:13:01 -0800
Message-ID: <20060307181301.4dd6aa96.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308015934.GB9062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752009AbWCHCPI@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060308015934.GB9062@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> +static inline void percpu_counter_mod_bh(struct percpu_counter *fbc, long amount)
>  +{
>  +	local_bh_disable();
>  +	percpu_counter_mod(fbc, amount);
>  +	local_bh_enable();
>  +}
>  +

percpu_counter_mod() does preempt_disable(), which is redundant in this
context.  So just do fbc->count += amount; here.
