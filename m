From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 3 Feb 2012 16:47:04 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:45438 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757922Ab2BCVr0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:47:26 -0500
In-Reply-To: <20120120.135028.1359677274445012541.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2012 01:50 PM, David Miller wrote:
> You were given an alternative way to trace these kinds of events, and 
> you have yet to give us a solid reason why that cannot work for you.

OK. I'll try to explain it.

First of all, we'd like to use this tracepoint with our
flight recorder.

tcpdump:
 tcpdump captures all the packets and so its overhead is not
 acceptable. Also we can't keep the data on memory but must
 write the data to file for each time. It introduce other
 overhead which we can't accept.

commit 63e03724b51, dropwatch, skb:kfree_skb:
 With this tracepoint, we can detect packet drop.
 But it may be too late because with tcp kernel retransmits
 packets repeatedly if it can't get ack and after that it
 may drops packets in a no-win situation.
 Also sometimes customer finds delays which is caused by
 temporal packet drop and retransmission. With this tracepoint
 we can explain it based on the real data.

netstat:
 This is a good tool for the first step to analyze what
 happened. But it shows only statistics and it's not enough
 for us to analyze incidents and explain it to our customers.
 We need each packet drop data(when it happen, whether it
 succeeded or not etc.)

systemtap:
 Actually, we've already used systemtap in our flight recorder.
 But we believe that tcp retransmission is one of the fundamental
 function in tcp stack and so kernel itself should provide the
 instruments from which we can get enough information.

Regards,
Satoru
