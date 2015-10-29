From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] ipv4: use l4 hash for locally generated
 multipath flows
Date: Thu, 29 Oct 2015 22:12:21 +0100
Message-ID: <1446153141.4787.2.camel@dhcp-176-88.mxp.redhat.com>
References: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
	 <1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
	 <1446132510.7476.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446137527.4431.25.camel@dhcp-176-88.mxp.redhat.com>
	 <1446144211.6254.2.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:40479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbbJ2VMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 17:12:25 -0400
In-Reply-To: <1446144211.6254.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 11:43 -0700, Eric Dumazet wrote:
> On Thu, 2015-10-29 at 17:52 +0100, Paolo Abeni wrote:
> > On Thu, 2015-10-29 at 08:28 -0700, Eric Dumazet wrote:
> > > On Thu, 2015-10-29 at 16:00 +0100, Paolo Abeni wrote:
> > > 
> > > > This patch do not add dissection code: it use the information provided
> > > > by the available flowi4 structure. Moreover the skb is not available on
> > > > the calling site (in __ip_route_output_key_hash) and pushing it all the
> > > > way will require a lot of intrusive changes. Do you think it's the
> > > > better option ?
> > > 
> > > If skb is provided, then we could use its information.
> > 
> > I see your point, but providing an skb to __ip_route_output_key_hash()
> > is not very viable: it has a lot of indirect callers which are
> > problematic, i.e.:
> > 
> > __ip_route_output_key()
> > ip_route_output_flow()
> > inet_csk_route_req()
> > tcp_v4_send_synack()  <- skb available here, but created using dst
> > information.
> > 
> 
> I never said it was trivial.
> 
> I said : "If skb is provided, then we can use its l4hash"
> 
> If not, then sure, a flow-based hash fallback is better than nothing.

Thank you for all the feedback. I'll resubmit using the flow-based hash.

Paolo
