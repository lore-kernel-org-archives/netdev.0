From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Thu, 28 Jan 2016 18:04:53 +0100
Message-ID: <1454000693.27229.15.camel@redhat.com>
References: <cover.1453830778.git.pabeni@redhat.com>
	 <88bb9789390b781edd13fc4bfaf9fec868f693dd.1453830778.git.pabeni@redhat.com>
	 <56AA2CE5.2050307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161416AbcA1RE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 12:04:58 -0500
In-Reply-To: <56AA2CE5.2050307@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 07:59 -0700, David Ahern wrote:
> On 1/27/16 6:45 AM, Paolo Abeni wrote:
> > The current implementation of ip6_dst_lookup_tail() basically
> > ignore the egress ifindex match: if the saddr is set,
> > ip6_route_output() purposefully ignores flowi6_oif, due
> > to the commit d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE
> > flag if saddr set"), if the saddr is 'any' the first route lookup
> > in ip6_dst_lookup_tail fails, but upon failure a second lookup will
> > be performed with saddr set, thus ignoring the ifindex constraint.
> >
> > This commit adds an output route lookup function variant, which
> > allows the caller to specify additional lookup flags, and modify
> > ip6_dst_lookup_tail() to enforce the ifindex match on the second
> > lookup via said helper.
> >
> > Fixes: d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set")
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> I don't agree with that 'Fixes:' tag.
> 
> ip6_route_output did not add the RT6_LOOKUP_F_IFACE flag until 
> 741a11d9e410; d46a9d678e4c is a follow on to limit adding the flag only 
> if no source address  is given.
> 
> Since ip6_dst_lookup_tail never considered the flowi6_oif this is a 
> general bug fix rather than a fix of d46a9d678e4c.

Ok, I'll remove it in the v2, which will include Hannes feedback, too.

Regards,

Paolo
