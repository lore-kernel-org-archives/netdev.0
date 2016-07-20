From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: fix implicit declaration of bpf_prog_add
Date: Wed, 20 Jul 2016 09:06:22 -0700
Message-ID: <20160720160620.GA76501@ast-mbp.thefacebook.com>
References: <1469026552-8975-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33296 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbcGTQG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:06:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id i6so3728379pfe.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:06:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469026552-8975-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 07:55:52AM -0700, Brenden Blanco wrote:
> For the ifndef case of CONFIG_BPF_SYSCALL, an inline version of
> bpf_prog_add needs to exist otherwise the build breaks on some configs.
> 
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2544:10: error: implicit declaration of function 'bpf_prog_add'
>        prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> 
> The function is introduced in
> 59d3656d5bf50 ("bpf: add bpf_prog_add api for bulk prog refcnt")
> and first used in
> 47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program").
> 
> Fixes: 47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Reported-by: Tariq Toukan <ttoukan.linux@gmail.com>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
