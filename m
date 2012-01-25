From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Wed, 25 Jan 2012 14:27:59 +0100
Message-ID: <02e98f84ee62073e1bf92338f6744fde@localhost>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<nhorman@tuxdriver.com>, <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44135 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752694Ab2AYN2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 08:28:02 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 20 Jan 2012 13:07:02 -0500, Satoru Moriya wrote:



> With this tracepoint, we can know whether the packet drop occurred

> in the server (moreover in the kernel) or not. For example, if we

> finds that retransmission failed (tcp_retransmit_skb() returned

> negative value), it means the kernel may have some troubles at

> that time and we can drill down on issues in the kernel based on

> trace data. OTOH, if retransmission succeeded, packet is dropped

> outside the kernel/server.





This is an equivalent replacement and by means not so intrusive:



probe kernel.function("tcp_retransmit_skb").return {

    printf("%s -> %d", probefunc(), retval())

}



and print inet_sk($sk)->inet_num for

kernel.function("tcp_retransmit_skb").



It is crazy to add everywhere new tracepoints. Systemtap is far from being

perfect and as smooth as dtrace. But this is an example where systemtap is

suitable and should be used.



Satoru, you wrote systemtap is not suitable - why?



Hagen
