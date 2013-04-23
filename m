From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Tue, 23 Apr 2013 14:59:01 +0800
Message-ID: <1366700341.21136.17.camel@cr0>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
	 <20130422.160834.1941810644323096368.davem@davemloft.net>
	 <1366687841.21136.6.camel@cr0> <1366698455.21136.11.camel@cr0>
	 <20130422235109.296696a4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755225Ab3DWG70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 02:59:26 -0400
In-Reply-To: <20130422235109.296696a4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 23:51 -0700, Stephen Hemminger wrote:
> On Tue, 23 Apr 2013 14:27:35 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > After several tries, I think it is not easy to do at all, it relies on
> > some icmp functions at least, which are still compiled as a module. So,
> > I can't think out any easier solution than simply adding Kconfig
> > dependency.
> 
> Why is IPv6 support depending on ICMP functions? Everything doesn't
> have to be hyper optimized, at least not initially.

VXLAN relies on IPv6 multicast which is on top of ICMPv6. At very least
igmp6_send() calls icmpv6_flow_init() and icmp6_dst_alloc() in the code.

Bridge multicast snooping only parses some multicast packets, which
seems much easier than maintaining multicast group ownership.

Yeah, I definitely agree on that we can fix this later, if David has no
objections.

Thanks.
