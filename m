From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Thu, 28 Jan 2016 07:59:49 -0700
Message-ID: <56AA2CE5.2050307@cumulusnetworks.com>
References: <cover.1453830778.git.pabeni@redhat.com>
 <88bb9789390b781edd13fc4bfaf9fec868f693dd.1453830778.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35395 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966273AbcA1O7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:59:53 -0500
Received: by mail-oi0-f53.google.com with SMTP id p187so27987512oia.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 06:59:52 -0800 (PST)
In-Reply-To: <88bb9789390b781edd13fc4bfaf9fec868f693dd.1453830778.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/16 6:45 AM, Paolo Abeni wrote:
> The current implementation of ip6_dst_lookup_tail() basically
> ignore the egress ifindex match: if the saddr is set,
> ip6_route_output() purposefully ignores flowi6_oif, due
> to the commit d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE
> flag if saddr set"), if the saddr is 'any' the first route lookup
> in ip6_dst_lookup_tail fails, but upon failure a second lookup will
> be performed with saddr set, thus ignoring the ifindex constraint.
>
> This commit adds an output route lookup function variant, which
> allows the caller to specify additional lookup flags, and modify
> ip6_dst_lookup_tail() to enforce the ifindex match on the second
> lookup via said helper.
>
> Fixes: d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

I don't agree with that 'Fixes:' tag.

ip6_route_output did not add the RT6_LOOKUP_F_IFACE flag until 
741a11d9e410; d46a9d678e4c is a follow on to limit adding the flag only 
if no source address  is given.

Since ip6_dst_lookup_tail never considered the flowi6_oif this is a 
general bug fix rather than a fix of d46a9d678e4c.
