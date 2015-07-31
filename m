From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add helpers to access tunnel metadata
Date: Fri, 31 Jul 2015 15:20:35 -0700 (PDT)
Message-ID: <20150731.152035.178009344109129845.davem@davemloft.net>
References: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbbGaWUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:20:36 -0400
In-Reply-To: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 30 Jul 2015 15:36:57 -0700

> Introduce helpers to let eBPF programs attached to TC manipulate tunnel metadata:
> bpf_skb_[gs]et_tunnel_key(skb, key, size, flags)
> skb: pointer to skb
> key: pointer to 'struct bpf_tunnel_key'
> size: size of 'struct bpf_tunnel_key'
> flags: room for future extensions
> 
> First eBPF program that uses these helpers will allocate per_cpu
> metadata_dst structures that will be used on TX.
> On RX metadata_dst is allocated by tunnel driver.
> 
> Typical usage for TX:
> struct bpf_tunnel_key tkey;
> ... populate tkey ...
> bpf_skb_set_tunnel_key(skb, &tkey, sizeof(tkey), 0);
> bpf_clone_redirect(skb, vxlan_dev_ifindex, 0);
> 
> RX:
> struct bpf_tunnel_key tkey = {};
> bpf_skb_get_tunnel_key(skb, &tkey, sizeof(tkey), 0);
> ... lookup or redirect based on tkey ...
> 
> 'struct bpf_tunnel_key' will be extended in the future by adding
> elements to the end and the 'size' argument will indicate which fields
> are populated, thereby keeping backwards compatibility.
> The 'flags' argument may be used as well when the 'size' is not enough or
> to indicate completely different layout of bpf_tunnel_key.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
