From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] samples: bpf: add userspace example for
 modifying sk_bound_dev_if
Date: Mon, 28 Nov 2016 12:37:54 -0800
Message-ID: <20161128203752.GC7634@ast-mbp.thefacebook.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
 <1480348130-31354-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36702 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753352AbcK1Uh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:37:58 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so14055311pgx.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:37:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480348130-31354-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 07:48:50AM -0800, David Ahern wrote:
> Add a simple program to demonstrate the ability to attach a bpf program
> to a cgroup that sets sk_bound_dev_if for AF_INET{6} sockets when they
> are created.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
> +static int prog_load(int idx)
> +{
> +	struct bpf_insn prog[] = {
> +		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
> +		BPF_MOV64_IMM(BPF_REG_3, idx),
> +		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
> +		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
> +		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
> +		BPF_EXIT_INSN(),
> +	};
> +
> +	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
> +			     "GPL", 0);
> +}

the program looks trivial enough :)

Could you integrate it into iproute2 as well ?
Then the whole vrf management will be easier.
The user wouldn't even need to be aware that iproute2 sets up
this program. It will know ifindex and can delete
the prog when vrf configs change and so on.

Also please convert this sample into automated test like samples/bpf/*.sh
we're going to move all of them to tools/testing/selftests/ eventually.
