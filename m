From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: Re: [PATCH v2 5/7] bpf: Add verifier test case for alignment.
Date: Thu, 11 May 2017 23:19:45 +0200
Message-ID: <20170511211945.GB20107@gmail.com>
References: <20170511.120601.246881624526451669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38267 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdEKVTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 17:19:49 -0400
Received: by mail-wm0-f46.google.com with SMTP id 142so51279076wma.1
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 14:19:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170511.120601.246881624526451669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 11, 2017 at 12:06:01PM -0400, David Miller wrote:
> 
> +static int do_test_single(struct bpf_align_test *test)
> +{
> +	struct bpf_insn *prog = test->insns;
> +	int prog_type = test->prog_type;
> +	int prog_len, i;
> +	int fd_prog;
> +	int ret;
> +
> +	prog_len = probe_filter_length(prog);
> +	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
> +				     prog, prog_len, 1, "GPL", 0,
> +				     bpf_vlog, sizeof(bpf_vlog));
> +	if (fd_prog < 0) {
> +		printf("Failed to load program.\n");
> +		printf("%s", bpf_vlog);
> +		ret = 1;
> +	} else {
> +		ret = 0;
> +		for (i = 0; i < MAX_MATCHES; i++) {
> +			const char *t, *m = test->matches[i];
> +
> +			if (!m)
> +				break;
> +			t = strstr(bpf_vlog, m);
> +			if (!t) {
> +				printf("Failed to find match: %s\n", m);
> +				ret = 1;
> +				printf("%s", bpf_vlog);
> +				break;
> +			}
> +		}
> +		/* printf("%s", bpf_vlog); */
Why is this commented out?

-- 
Mit freundlichen Grüßen

Alexander Alemayhu
