From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH 0/2] Tracepoint for tcp retransmission
Date: Tue, 20 Dec 2011 18:40:19 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFB01E@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
 <5f654c7d-f18e-4d70-8830-a3e31b8f5f4a@tahiti.vyatta.com>
 <20111218004944.GB14903@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:38556 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab1LTXlM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 18:41:12 -0500
In-Reply-To: <20111218004944.GB14903@hell>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/17/2011 07:49 PM, Hagen Paul Pfeifer wrote:
>> Sometimes network packets are dropped for some reason. In enterprise 
>> systems which require strict RAS functionality, we must know the 
>> reason why it happened and explain it to our customers even if using 
>> TCP. When we investigate the incidents, at first we try to find out 
>> whether the problem is in the server(kernel, application) or else 
>> (router, hub etc). And next we try to find out which layer
>> (application/middleware/kernel(IP/TCP/UDP/..)etc.) the problem 
>> occurs.
> 
> For the first question tcpdump may the right tool.

We'd like to keep records on memory and save it to file when
we detect problems so that we can keep tracing overhead low.
We can also keep the amount of trace data lower than with
tcpdump because we only record data when retransmission occurs.

Capturing all the packets and saving them to file cannot satisfy
our requirements. I should have written them in the cover-letter.
I'll fix it.

Also, we can analyze incidents in combination with the data
from this tracepoint and from others easily.

> For the later systemtap can be used. I mean we now have the 
> possibility to instrument the kernel at runtime, without bloating the 
> source.

Yes, we can use systemtap to get the data we need. But systemtap
is not included in kernel and we must maintain systemtap scripts
to follow kernel modification.

By adding tracepoint here, we can get useful data via ftrace/perf
without any instruments which is not included in kernel.
Of course, systemtap can insert a probe with this tracepoint too.

> Anyway: is 63e03724b51 not suitable to gather the required information 
> easily?

We use trace_kfree_skb() which 63e03724b51 uses to detect packet
drop event. In addition to that, we would like to detect errors
in TCP layer for better trouble shooting.

Regards,
Satoru
