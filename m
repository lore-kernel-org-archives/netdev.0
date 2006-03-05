From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Sun, 5 Mar 2006 00:45:34 -0800
Message-ID: <20060305004534.1d94b3cf.akpm@osdl.org>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<20060303214236.11908.98881.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752155AbWCEIrJ@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060303214236.11908.98881.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +#ifdef CONFIG_NET_DMA
>  +	tp->ucopy.dma_chan = NULL;
>  +	if ((len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) && !sysctl_tcp_low_latency && __get_cpu_var(softnet_data.net_dma))
>  +		dma_lock_iovec_pages(msg->msg_iov, len, &tp->ucopy.locked_list);
>  +#endif

The __get_cpu_var() here will run smp_processor_id() from preemptible
context.  You'll get a big warning if the correct debug options are set.

The reason for this is that preemption could cause this code to hop between
CPUs.

Please always test code with all debug options enabled and with full kernel
preemption.
