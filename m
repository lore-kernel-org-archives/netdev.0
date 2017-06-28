From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v4 01/16] bpf: BPF support for sock_ops
Date: Wed, 28 Jun 2017 12:53:43 -0700
Message-ID: <4c9020de-80c6-2b70-d9db-1759ea579780@fb.com>
References: <20170628173124.3299500-1-brakmo@fb.com>
 <20170628173124.3299500-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32845 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751554AbdF1TyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 15:54:13 -0400
In-Reply-To: <20170628173124.3299500-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/17 10:31 AM, Lawrence Brakmo wrote:
> +#ifdef CONFIG_BPF
> +static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
> +{
> +	struct bpf_sock_ops_kern sock_ops;
> +	int ret;
> +
> +	if (!is_req_sock)
> +		sock_owned_by_me(sk);
> +
> +	memset(&sock_ops, 0, sizeof(sock_ops));
> +	sock_ops.sk = sk;
> +	sock_ops.is_req_sock = is_req_sock;
> +	sock_ops.op = op;
> +
> +	ret = BPF_CGROUP_RUN_PROG_SOCK_OPS(&sock_ops);
> +	if (ret == 0)
> +		ret = sock_ops.reply;
> +	else
> +		ret = -1;
> +	return ret;
> +}

the switch to cgroup attached only made it really nice and clean.
No global state to worry about.
I haven't looked through the minor patch details, but overall
it all looks good to me. I don't have any architectural concerns.

Acked-by: Alexei Starovoitov <ast@kernel.org>
