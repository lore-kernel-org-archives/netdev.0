From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v10 00/12] Add driver bpf hook for early packet drop and
 forwarding
Date: Wed, 20 Jul 2016 07:08:59 -0700
Message-ID: <20160720140827.GA11588@gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <20160719.220959.1735534229001351021.davem@davemloft.net>
 <6a09ce5d-f902-a576-e44e-8e1e111ae26b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, saeedm@dev.mellanox.co.il, kafai@fb.com,
	brouer@redhat.com, as754m@att.com, alexei.starovoitov@gmail.com,
	gerlitz.or@gmail.com, john.fastabend@gmail.com,
	hannes@stressinduktion.org, tgraf@suug.ch, tom@herbertland.com,
	daniel@iogearbox.net
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36291 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbcGTOJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 10:09:05 -0400
Received: by mail-pf0-f174.google.com with SMTP id h186so19591024pfg.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 07:09:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6a09ce5d-f902-a576-e44e-8e1e111ae26b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 12:18:49PM +0300, Tariq Toukan wrote:
> 
> On 20/07/2016 8:09 AM, David Miller wrote:
> >From: Brenden Blanco <bblanco@plumgrid.com>
> >Date: Tue, 19 Jul 2016 12:16:45 -0700
> >
> >>This patch set introduces new infrastructure for programmatically
> >>processing packets in the earliest stages of rx, as part of an effort
> >>others are calling eXpress Data Path (XDP) [1]. Start this effort by
> >>introducing a new bpf program type for early packet filtering, before
> >>even an skb has been allocated.
> >>
> >>Extend on this with the ability to modify packet data and send back out
> >>on the same port.
> >Series applied, thanks.
> 
> Hi Dave,
> 
> The series causes compilation errors in our driver (and warnings).
> Please revert it.
My bad. The kbuild robot caught it as well. As an alternative to revert,
I can also send a patch to add the necessary inline stub.
> 
> *23:08:37*drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In
> function 'mlx4_xdp_set':
> 
> *23:08:37*drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2566:4:
> error: implicit declaration of function 'bpf_prog_add'
> [-Werror=implicit-function-declaration]
> 
> *23:08:37*    prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> 
> *23:08:37*    ^
> 
> *23:08:37*  CC [M]  drivers/gpu/drm/nouveau/nvkm/subdev/i2c/padgm200.o
> 
> *23:08:37*drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2566:9:
> warning: assignment makes pointer from integer without a cast
> [enabled by default]
> 
> *23:08:37*    prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> 
> *23:08:37*         ^
> 
> *23:08:37*drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2592:8:
> warning: assignment makes pointer from integer without a cast
> [enabled by default]
> 
> *23:08:37*   prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
> 
> *23:08:37*        ^
> 
> *23:08:37*cc1: some warnings being treated as errors
> 
> *23:08:37*make[7]: ***
> [drivers/net/ethernet/mellanox/mlx4/en_netdev.o] Error 1
> 
> *23:08:37*make[7]: *** Waiting for unfinished jobs....
> 
> *23:08:37*  CC      drivers/tty/serial/8250/8250_pnp.o
> 
> 
