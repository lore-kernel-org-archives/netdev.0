From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Mon, 11 Jan 2016 22:00:08 -0800
Message-ID: <20160112060007.GB31180@ast-mbp.thefacebook.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
 <CACVXFVNhEOrroAfiEOC32dB3ZV=73WYJxUtNrpqEE94tvY2fXw@mail.gmail.com>
 <20160109004443.GA33292@kafai-mba.local>
 <CACVXFVPbsqBoAvgRjrm7A3S2G0kUrEt=e64FyRpoSqO2ukHncQ@mail.gmail.com>
 <20160110022946.GA50678@kevintjones-mbp.dhcp.thefacebook.com.DHCP.thefacebook.com>
 <CACVXFVNfRLL-TQajPHD1XKnFCgyTvU_dAJQ0+HxwYQX4qC1G8A@mail.gmail.com>
 <20160111223444.GA6742@kafai-mba.dhcp.thefacebook.com>
 <CACVXFVMZRS5fxta6xvehfzQHW37KxWSs630_6MO1s+GRyb0teQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin KaFai Lau <kafai@fb.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVMZRS5fxta6xvehfzQHW37KxWSs630_6MO1s+GRyb0teQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 12, 2016 at 01:48:10PM +0800, Ming Lei wrote:
> The total memory consumption is still much less than memory consumed
> by percpu hash since a new element is only added to hash if the key is run
> on that CPU. Most of times, for one key it may touch very few CPUs.
> 
> For percpu hash, the memory is always allocated to every CPU no matter
> if the key is run from the CPU.

In Martin's use case all cpus are servicing network traffic and all of them
are counting packets.

> In my test, removing the current kmalloc() in update element callback can
> improve io thoughput by 10% not mention the percpu ida allocation cost, and
> looks it isn't cheap. That is why I don't think it is good to
> introduce another new
> allocation in the eBPF prog path.

I don't think anyone is arguing that pre-allocation is not needed.
In some cases better performance can be achieved with pre-allocation,
in some other cases regular hash map will be enough,
and in others hash map with per-cpu is needed as well.

> You can find my test in the link below:
> 
>        https://patchwork.ozlabs.org/patch/556926/

yes, for tools/biolatency pre-allocation is a win,
but in many other cases we simply cannot pre-allocate all elements.
