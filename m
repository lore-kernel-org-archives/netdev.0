From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: missing kfree_skb(skb) in ipv6_frag_rcv()?
Date: Mon, 23 Sep 2013 11:37:11 -0700
Message-ID: <1379961431.3165.25.camel@edumazet-glaptop>
References: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7354@saturn3.aculab.com>
	 <1379955122.2485.47.camel@bwh-desktop.uk.level5networks.com>
	 <2134F8430051B64F815C691A62D983181101B8@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:38913 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302Ab3IWShW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:37:22 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so3546300pdj.36
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 11:37:21 -0700 (PDT)
In-Reply-To: <2134F8430051B64F815C691A62D983181101B8@XCH-BLV-504.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 17:42 +0000, Templin, Fred L wrote:
> Hello,
> 
> In the most recent kernel releases, in ./net/ipv6/reassembly.c,
> I see the following code at the end of "ipv6_frag_rcv()":
> 
> +	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMFAILS);
> +	kfree_skb(skb);
> +	return -1;
> +
> +fail_hdr:
> +	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
> +	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
> +	return -1;
> +}
> 
> Perhaps I missed it, but I did not find anywhere that 'icmpv6_param_prob()'
> frees the skb, and hence it appears that there is a missing kfree_skb()
> in the above code. Is this a bug?

void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
{
        icmp6_send(skb, ICMPV6_PARAMPROB, code, pos);
        kfree_skb(skb);
}

Well, I do see kfree_skb(skb) here.
