From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx5e: Query minimum required header
 copy during xmit
Date: Wed, 20 Jul 2016 22:15:31 -0700
Message-ID: <20160721051529.GA89065@ast-mbp.thefacebook.com>
References: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
 <1469053202-30649-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36653 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcGUFPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 01:15:38 -0400
Received: by mail-yw0-f193.google.com with SMTP id u134so4794310ywg.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 22:15:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469053202-30649-3-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 01:20:02AM +0300, Saeed Mahameed wrote:
> From: Hadar Hen Zion <hadarh@mellanox.com>
> 
> Add support for query the minimum inline mode from the Firmware.
> It is required for correct TX steering according to L3/L4 packet
> headers.
> 
> Each send queue (SQ) has inline mode that defines the minimal required
> headers that needs to be copied into the SQ WQE.
> The driver asks the Firmware for the wqe_inline_mode device capability
> value.  In case the device capability defined as "vport context" the
> driver must check the reported min inline mode from the vport context
> before creating its SQs.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
...
> +	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
> +	u32 *out;
> +
> +	out = mlx5_vzalloc(outlen);
> +	if (!out)
> +		return;

Just discovered this...
outlen is a small constant here, yet you want to try to vmalloc it?
What is the point?
There are 67 places in mlx5 where failed kmalloc is retried with
vmalloc... was that path ever tested?
