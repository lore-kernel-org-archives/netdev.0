From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next fragmentation icmp v4 3/4] bridge_netfilter: No ICMP
 packet on IPv4 defragmentation timeout
Date: Thu, 14 May 2015 10:59:40 +0200
Message-ID: <20150514085940.GD6179@breakpoint.cc>
References: <1431570482-9236-1-git-send-email-azhou@nicira.com>
 <1431570482-9236-4-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45413 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbbENI7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 04:59:43 -0400
Content-Disposition: inline
In-Reply-To: <1431570482-9236-4-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Zhou <azhou@nicira.com> wrote:
> Currently, on defragmentation timeout error, ICMP error message
> will be generated. This is fine when they are used in a routing context,
> but does not make sense in the context of bridging netfilter.
> 
> This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
> whether ICMP error message should be generated. br_netfiler sets
> this bit.

Could you please explain why we need this patch?
After the previous change (patch 2 in your series), we will already
bail out before hitting

/* Send an ICMP "Fragment Reassembly Timeout" message. */
icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);

in ip_expire() based on qp->user value test?
