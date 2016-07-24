From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] bpf: Add bpf_probe_write_user BPF helper
 to be called in tracers
Date: Sat, 23 Jul 2016 18:13:52 -0700
Message-ID: <20160724011350.GA33568@ast-mbp.thefacebook.com>
References: <20160724004347.GA31776@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160724004347.GA31776@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 05:43:48PM -0700, Sargun Dhillon wrote:
> This allows user memory to be written to during the course of a kprobe.
> It shouldn't be used to implement any kind of security mechanism
> because of TOC-TOU attacks, but rather to debug, divert, and
> manipulate execution of semi-cooperative processes.
> 
> Although it uses probe_kernel_write, we limit the address space
> the probe can write into by checking the space with access_ok.
> This is so the call doesn't sleep. In addition we ensure the threads's
> current fs / segment is USER_DS and the thread isn't exiting nor
> a kernel thread.
> 
> Given this feature is experimental, and has the risk of crashing the
> system, we print a warning on first invocation, and the process name
> on subsequent invocations.
> 
> It was tested with the tracex7 program on x86-64.

s/tracex7/test_probe_write_user form the next patch/
or just drop this sentence.

> +static const struct bpf_func_proto *bpf_get_probe_write_proto(void) {
> +	pr_warn_ratelimited("bpf_probe_write_user: %s[%d] installing program with helper: it may corrupt user memory!",
> +	current->comm, task_pid_nr(current));

I think checkpatch should have complained here.
current->comm line should start under "

No other nits for this patch :)
Once fixed, feel free to add my Acked-by: Alexei Starovoitov <ast@kernel.org>
