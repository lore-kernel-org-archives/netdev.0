From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sat, 4 Feb 2012 16:58:07 +0100
Message-ID: <20120204155807.GA2657@nuttenaction>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:49558 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752058Ab2BDP6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 10:58:10 -0500
Content-Disposition: inline
In-Reply-To: <20120204142823.GA7000@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Neil Horman | 2012-02-04 09:28:23 [-0500]:

>So, I hadn't really considered this approach (missed the suggestion previously).
>Its not really accurate to disregard this solution entirely.  While the overhead
>of tcpdump (or libpcap more specifically) might be too much, it speaks to a
>possible solution that doesn't require adding additional tracepoints: a
>netfilter hook.  What about writing a kernel module to hook at various points
>(I'd guess IP_PREROUTE would be best), to detect duplicate sequence numbers on a
>particular connection.  You could export the information via a proc file, or do
>it asynchronously with a netlink socket or some such.  Thats the sort of module
>that pleasantly isolated (allow those not interested to not have to include it
>in their builds or see it in the source), efficiently provides the information
>you need, and can be expanded to other types of traffic should you need it in
>the future.

That sounds broken by design. Copy TCP sequence number mechanism one more time
as a netfilter module? You probably catch the retransmission drop with this,
but users *want* more: in one week Satoru realize that the retransmission
tracepoint doesn't cover all required information for their customer. Other
user may need information about TCP rate-halfing-SACK-rto-foo drops. You will
and up realizing that in-packet data (like sequence number) is not sufficient
for correct analysis. Ask Yuchung how many tracepoints they use. Maybe Google
guys should publish their git network-stack-trace topic branch, like the rt
branch: everybody who want more tracing should pull from this branch. (ok, too
revolutionary ;-)

What is required is a context aware tracing mechanism with no overhead and no
code modification ... Mmhh ... systemtap! ;-)

The problem is the usability of systemtap. One problem is that the scripts are
maintained out of kernel development (maybe) and thus source code
modifications are not aligned (kernel and systemtap scripts). IMO that's one
of the drawbacks of systemap. But maybe this is no problem in praxis:
end-customers normally use stable kernels for a longer time.

Hagen
