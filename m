From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Fri, 20 Nov 2015 18:27:10 -0500
Message-ID: <20151120232710.GC10508@oracle.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448054520-1464587-5-git-send-email-tom@herbertland.com>
 <20151120225012.GB10508@oracle.com>
 <CALx6S36p3RAy+7ZO6G=MjAyLz95zr-UD7AUaFe8kS8EVUHHFNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17140 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbKTX1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 18:27:21 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S36p3RAy+7ZO6G=MjAyLz95zr-UD7AUaFe8kS8EVUHHFNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/20/15 15:19), Tom Herbert wrote:
> 
> I did notice that RDS is just creating sglist, but I also noticed that
> this requires allocating "struct rds_message" which holds pointers to
> the sglist, list pointers for a queue, etc. This looks to me like its
> emulating skbuffs anyway. I haven't looked if there's performance

yes, some of that might come from the IB origins of the code
so that it could be shared with an IB transport. I was just wondering
if directly using sk_buffs would be a significant perf win for rds-tcp.

> issues otherwise in using the fraglist. It might be interesting if
> there was an interface to send skbufs on a kernel socket.

yes. Or if there was a way to  factor out the non-zero page-order
enhancements in skb_page_frag_refill in a way that they could be
shared with RDS.

--Sowmini
