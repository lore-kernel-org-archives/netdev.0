From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Fri, 29 Jan 2016 13:33:47 +0100
Message-ID: <56AB5C2B.9030307@stressinduktion.org>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50295 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbcA2Mdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 07:33:53 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 0731120450
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 07:33:52 -0500 (EST)
In-Reply-To: <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2016 12:30, Paolo Abeni wrote:
> The current implementation of ip6_dst_lookup_tail basically
> ignore the egress ifindex match: if the saddr is set,
> ip6_route_output() purposefully ignores flowi6_oif, due
> to the commit d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE
> flag if saddr set"), if the saddr is 'any' the first route lookup
> in ip6_dst_lookup_tail fails, but upon failure a second lookup will
> be performed with saddr set, thus ignoring the ifindex constraint.
>
> This commit adds an output route lookup function variant, which
> allows the caller to specify lookup flags, and modify
> ip6_dst_lookup_tail() to enforce the ifindex match on the second
> lookup via said helper.
>
> ip6_route_output() becames now a static inline function build on
> top of ip6_route_output_flags(); as a side effect, out-of-tree
> modules need now a GPL license to access the output route lookup
> functionality.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> --
> v1 -> v2 move the ip6_route_output() implementation into the header

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
