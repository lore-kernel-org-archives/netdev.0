From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Fri, 29 Jan 2016 09:00:07 -0700
Message-ID: <56AB8C87.1010904@cumulusnetworks.com>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36322 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbcA2QAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 11:00:12 -0500
Received: by mail-ob0-f170.google.com with SMTP id ba1so66502046obb.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 08:00:12 -0800 (PST)
In-Reply-To: <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/16 4:30 AM, Paolo Abeni wrote:
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

Acked-by: David Ahern <dsa@cumulusnetworks.com>
