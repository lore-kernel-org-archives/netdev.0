From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/4] net: percpufy frequently used vars -- struct
 proto.memory_allocated
Date: Tue, 7 Mar 2006 18:14:22 -0800
Message-ID: <20060307181422.3e279ca1.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308020118.GC9062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752034AbWCHCQn@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060308020118.GC9062@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> -	if (atomic_read(sk->sk_prot->memory_allocated) < sk->sk_prot->sysctl_mem[0]) {
>  +	if (percpu_counter_read(sk->sk_prot->memory_allocated) <
>  +			sk->sk_prot->sysctl_mem[0]) {

Bear in mind that percpu_counter_read[_positive] can be inaccurate on large
CPU counts.

It might be worth running percpu_counter_sum() to get the exact count if we
think we're about to cause something to fail.
