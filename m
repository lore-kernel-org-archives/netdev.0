From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large packets
Date: Fri, 6 Sep 2013 17:36:42 +0100
Message-ID: <522A049A.7000105@citrix.com>
References: <20130906101635.GI14104@zion.uk.xensource.com> <1378472268.31445.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:1834 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755492Ab3IFQgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 12:36:47 -0400
In-Reply-To: <1378472268.31445.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/13 13:57, Eric Dumazet wrote:
> Well, I have no problem to get line rate on 20Gb with a single flow, so
> other drivers have no problem.
I've made some tests on bare metal:
Dell PE R815, Intel 82599EB 10Gb, 3.11-rc4 32 bit kernel with 3.17.3 
ixgbe (TSO, GSO on), iperf 2.0.5
Transmitting packets toward the remote end (so running iperf -c on this 
host) can make 8.3 Gbps with the default 128k tcp_limit_output_bytes. 
When I increased this to 131.506 (128k + 434 bytes) suddenly it jumped 
to 9.4 Gbps. Iperf CPU usage also jumped a few percent from ~36 to ~40% 
(softint percentage in top also increased from ~3 to ~5%)
So I guess it would be good to revisit the default value of this 
setting. What hw you used Eric for your 20Gb results?

Regards,

Zoli
