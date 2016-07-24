From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 2/2] samples/bpf: Add test/example of using
 bpf_probe_write_user bpf helper
Date: Sat, 23 Jul 2016 18:17:58 -0700
Message-ID: <20160724011757.GB33568@ast-mbp.thefacebook.com>
References: <20160724004410.GA31798@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160724004410.GA31798@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 05:44:11PM -0700, Sargun Dhillon wrote:
> This example shows using a kprobe to act as a dnat mechanism to divert
> traffic for arbitrary endpoints. It rewrite the arguments to a syscall
> while they're still in userspace, and before the syscall has a chance
> to copy the argument into kernel space.
> 
> Although this is an example, it also acts as a test because the mapped
> address is 255.255.255.255:555 -> real address, and that's not a legal
> address to connect to. If the helper is broken, the example will fail.

nice. makes sense.

> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
...
> +/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com

hmm, not sure what to think about this line.
plumgrid got a new employee? ;)

> +	if (load_bpf_file(filename)) {
> +		printf("%s", bpf_log_buf);
> +		return 1;
> +	}
> +
> +	/* Is the server's getsockname = the socket getpeername */
> +	assert(memcmp(&serv_addr, &tmp_addr, sizeof(struct sockaddr_in)) == 0);

thanks. so the $?==0 will indicate success, right?
After respin feel free to add my ack.
