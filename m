From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 04:59:18 -0700
Message-ID: <1459425558.6473.229.camel@edumazet-glaptop3.roam.corp.google.com>
References: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net>
	 <20160331011840.GA50846@ast-mbp.thefacebook.com>
	 <20160331050115.GA21665@unicorn.suse.cz>
	 <20160331050808.GA56499@ast-mbp.thefacebook.com>
	 <20160331052232.GB21665@unicorn.suse.cz>
	 <20160331054301.GA57227@ast-mbp.thefacebook.com>
	 <56FD0B79.5020007@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Michal Kubecek <mkubecek@suse.cz>, davem@davemloft.net,
	sasha.levin@oracle.com, jslaby@suse.cz, mst@redhat.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35256 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbcCaL7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 07:59:22 -0400
Received: by mail-yw0-f172.google.com with SMTP id g127so94163150ywf.2
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 04:59:21 -0700 (PDT)
In-Reply-To: <56FD0B79.5020007@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-31 at 13:35 +0200, Daniel Borkmann wrote:

> +static inline bool sock_owned_externally(const struct sock *sk)
> +{
> +	return sk->sk_flags & (1UL << SOCK_EXTERNAL_OWNER);
> +}
> +

Have you reinvented sock_flag(sl, SOCK_EXTERNAL_OWNER) ? ;)

Anyway, using a flag for this purpose sounds overkill to me.

Setting it is a way to 'fool' lockdep anyway...
