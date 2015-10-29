From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] ipv4: use l4 hash for locally generated
 multipath flows
Date: Thu, 29 Oct 2015 16:00:59 +0100
Message-ID: <1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
References: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
	 <1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter =?ISO-8859-1?Q?N=F8rlund?= <pch@ordbogen.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757488AbbJ2PBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 11:01:12 -0400
In-Reply-To: <1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 07:31 -0700, Eric Dumazet wrote:
> On Wed, 2015-10-28 at 18:39 +0100, Paolo Abeni wrote:
> > This patch changes how the multipath hash is computed for locally
> > generated UDP or TCP flows: now the hash comprises also l4 information
> > (source and destination port).
> > 
> > This allows better utilization of the available paths when the existing
> > flows have the same source IP and the same destination IP: with l3 hash,
> > even when multiple connections are in place simultaneously, a single path
> > will be used, while with l4 hash we can use all the available paths.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Please note that many skb already have a l4 hash. No need to perform yet
> another dissection.

This patch do not add dissection code: it use the information provided
by the available flowi4 structure. Moreover the skb is not available on
the calling site (in __ip_route_output_key_hash) and pushing it all the
way will require a lot of intrusive changes. Do you think it's the
better option ?

Paolo
