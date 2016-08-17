From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 2/5] cgroup: add bpf_{e,in}gress pointers
Date: Wed, 17 Aug 2016 10:50:40 -0700
Message-ID: <20160817175038.GB98226@ast-mbp.thefacebook.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-3-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
	davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36187 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcHQSFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 14:05:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so8485320pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 11:04:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471442448-1248-3-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 04:00:45PM +0200, Daniel Mack wrote:
> Add two pointers for eBPF programs to struct cgroup. These will be used
> to store programs for ingress and egress for accounting and filtering.
> 
> This new feature is guarded by CONFIG_CGROUP_BPF.
...
> +#ifdef CONFIG_CGROUP_BPF
> +	/* used by the networking layer */
> +	struct bpf_prog *bpf_ingress;
> +	struct bpf_prog *bpf_egress;
> +#endif
...
> +config CGROUP_BPF
> +	bool "Enable eBPF programs in cgroups"
> +	depends on BPF_SYSCALL
> +	help
> +	  This options allows cgroups to accommodate eBPF programs that
> +	  can be used for network traffic filtering and accounting. See
> +	  Documentation/networking/filter.txt for more information.
> +

I think this extra config is unnecessary. It makes the code harder to follow.
Anyone turning on bpf syscall and cgroups should be able to have this feature.
Extra config is imo overkill.
