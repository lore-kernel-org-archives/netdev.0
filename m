From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add support for %s specifier to
 bpf_trace_printk()
Date: Thu, 27 Aug 2015 15:34:09 -0700 (PDT)
Message-ID: <20150827.153409.893765406170260565.davem@davemloft.net>
References: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, rostedt@goodmis.org, wangnan0@huawei.com,
	hekuang@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 26 Aug 2015 23:26:59 -0700

> +/* similar to strncpy_from_user() but with extra checks */
> +static void probe_read_string(char *buf, int size, long unsafe_ptr)
> +{
> +	char dst[4];
> +	int i = 0;
> +
> +	size--;
> +	for (;;) {
> +		if (probe_kernel_read(dst, (void *) unsafe_ptr, 4))
> +			break;

I don't think this does the right thing when the string is not a multiple
of 3 and ends at the last byte of a page that ends a valid region of
kernel memory.

Seeing this kind of error makes me skeptical to the overall value of
optimizing this :-/
