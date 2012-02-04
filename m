From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sat, 4 Feb 2012 09:28:23 -0500
Message-ID: <20120204142823.GA7000@neilslaptop.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38911 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2BDO2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 09:28:43 -0500
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2012 at 04:47:04PM -0500, Satoru Moriya wrote:
> On 01/20/2012 01:50 PM, David Miller wrote:
> > You were given an alternative way to trace these kinds of events, and 
> > you have yet to give us a solid reason why that cannot work for you.
> 
> OK. I'll try to explain it.
> 
> First of all, we'd like to use this tracepoint with our
> flight recorder.
> 
> tcpdump:
>  tcpdump captures all the packets and so its overhead is not
>  acceptable. Also we can't keep the data on memory but must
>  write the data to file for each time. It introduce other
>  overhead which we can't accept.
> 
So, I hadn't really considered this approach (missed the suggestion previously).
Its not really accurate to disregard this solution entirely.  While the overhead
of tcpdump (or libpcap more specifically) might be too much, it speaks to a
possible solution that doesn't require adding additional tracepoints: a
netfilter hook.  What about writing a kernel module to hook at various points
(I'd guess IP_PREROUTE would be best), to detect duplicate sequence numbers on a
particular connection.  You could export the information via a proc file, or do
it asynchronously with a netlink socket or some such.  Thats the sort of module
that pleasantly isolated (allow those not interested to not have to include it
in their builds or see it in the source), efficiently provides the information
you need, and can be expanded to other types of traffic should you need it in
the future.

Thoughts?
Neil

> 
