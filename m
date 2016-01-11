From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] bpf: support ipv6 for
 bpf_skb_{set,get}_tunnel_key
Date: Sun, 10 Jan 2016 16:35:08 -0800
Message-ID: <20160111003507.GB21834@ast-mbp.thefacebook.com>
References: <cover.1452385316.git.daniel@iogearbox.net>
 <cd5fc9d4b8de9a804923b3a96bbc0809473d35ff.1452385316.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35789 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbcAKAfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 19:35:09 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so51701245pac.2
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 16:35:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <cd5fc9d4b8de9a804923b3a96bbc0809473d35ff.1452385316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 01:16:39AM +0100, Daniel Borkmann wrote:
> After IPv6 support has recently been added to metadata dst and related
> encaps, add support for populating/reading it from an eBPF program.
> 
> Commit d3aa45ce6b ("bpf: add helpers to access tunnel metadata") started
> with initial IPv4-only support back then (due to IPv6 metadata support
> not being available yet).
> 
> To stay compatible with older programs, we need to test for the passed
> structure size. Also TOS and TTL support from the ip_tunnel_info key has
> been added. Tested with vxlan devs in collect meta data mode with IPv4,
> IPv6 and in compat mode over different network namespaces.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
...
>  struct bpf_tunnel_key {
>  	__u32 tunnel_id;
> -	__u32 remote_ipv4;
> +	union {
> +		__u32 remote_ipv4;
> +		__u32 remote_ipv6[4];
> +	};
> +	__u8 tunnel_tos;
> +	__u8 tunnel_ttl;
>  };

Acked-by: Alexei Starovoitov <ast@kernel.org>

was hoping that you would mention that people should upgrade
their llvm to 3.7 release or later, since old pre-release
had a bug when dealing with such structs and some
'lazy' folks may still be running some old version ;)

btw, three minor bugs were fixed after 3.7 was released.
llvm 3.7.1 and 3.8 have no known issues in bpf backend.
