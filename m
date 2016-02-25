From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix csum setting for bpf_set_tunnel_key
Date: Thu, 25 Feb 2016 11:45:47 +0100
Message-ID: <56CEDB5B.7060805@iogearbox.net>
References: <cb92edae7e6cb23d349d714736362535e56a1c75.1456188678.git.daniel@iogearbox.net> <20160224.162400.1248598061435588351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, jesse@kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42343 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759853AbcBYKpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 05:45:52 -0500
In-Reply-To: <20160224.162400.1248598061435588351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2016 10:24 PM, David Miller wrote:
[...]
> Applied to 'net', thanks Daniel.

Thanks!

Btw, in case net gets merged into net-next, there will be a minor
merge conflict due to stackid flags present in net-next. This can
be easily resolved by keeping both chunks.

For example, result after merge in include/uapi/linux/bpf.h then
looks like:

/* BPF_FUNC_skb_set_tunnel_key and BPF_FUNC_skb_get_tunnel_key flags. */
#define BPF_F_TUNINFO_IPV6              (1ULL << 0)

/* BPF_FUNC_skb_set_tunnel_key flags. */
#define BPF_F_ZERO_CSUM_TX              (1ULL << 1)

/* BPF_FUNC_get_stackid flags. */
#define BPF_F_SKIP_FIELD_MASK           0xffULL
#define BPF_F_USER_STACK                (1ULL << 8)
#define BPF_F_FAST_STACK_CMP            (1ULL << 9)
#define BPF_F_REUSE_STACKID             (1ULL << 10)

Thanks,
Daniel
