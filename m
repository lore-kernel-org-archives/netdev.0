From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Mon, 20 Jun 2016 19:18:38 -0700
Message-ID: <20160621021836.GA81638@ast-mbp.thefacebook.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com>
 <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36043 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbcFUCSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 22:18:44 -0400
Received: by mail-pf0-f196.google.com with SMTP id i123so206058pfg.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 19:18:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 18, 2016 at 01:31:26AM +0300, Saeed Mahameed wrote:
> 
> We simply want to selectively be able to see RoCE/RDMA ETH standard
> traffic in tcpdump, for diagnostic purposes.
> so in order to not overwhelm the kernel TCP/IP stack with this
> traffic, this patch in particular
> configures ConnectX4 hardware to tag those packets, so in downstream
> patches mlx5 netdevice will mark the SKBs of those packets
> to skip the TCP/IP stack and go only to tcpdump.

such 'feature' doesn't make sense to me.
'not overwhelming' kernel, but to 'overwhelm' userspace tcpdump?
Kernel can drop packets way faster than userspace, so such bypass
scheme has no prartical usage other than building a first step towards
complete dpdk-like bypass.
