From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix csum setting for bpf_set_tunnel_key
Date: Wed, 24 Feb 2016 16:24:00 -0500 (EST)
Message-ID: <20160224.162400.1248598061435588351.davem@davemloft.net>
References: <cb92edae7e6cb23d349d714736362535e56a1c75.1456188678.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, jesse@kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbcBXVYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:24:02 -0500
In-Reply-To: <cb92edae7e6cb23d349d714736362535e56a1c75.1456188678.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 23 Feb 2016 02:05:26 +0100

> The fix in 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be correctly
> controlled.") changed behavior for bpf_set_tunnel_key() when in use with
> IPv6 and thus uncovered a bug that TUNNEL_CSUM needed to be set but wasn't.
> As a result, the stack dropped ingress vxlan IPv6 packets, that have been
> sent via eBPF through collect meta data mode due to checksum now being zero.
> 
> Since after LCO, we enable IPv4 checksum by default, so make that analogous
> and only provide a flag BPF_F_ZERO_CSUM_TX for the user to turn it off in
> IPv4 case.
> 
> Fixes: 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be correctly controlled.")
> Fixes: c6c33454072f ("bpf: support ipv6 for bpf_skb_{set,get}_tunnel_key")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied to 'net', thanks Daniel.
