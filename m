From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bpf: add helpers to access tunnel metadata
Date: Fri, 31 Jul 2015 10:11:17 +0200
Message-ID: <20150731081117.GC4738@pox.localdomain>
References: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37839 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbbGaILU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 04:11:20 -0400
Received: by wibud3 with SMTP id ud3so21512262wib.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 01:11:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438295817-27295-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/15 at 03:36pm, Alexei Starovoitov wrote:
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

Very nice! For the dst metadata bits:

Acked-by: Thomas Graf <tgraf@suug.ch>
