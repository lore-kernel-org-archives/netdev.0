From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: TCP: Support configurable delayed-ack parameters
Date: Fri, 28 Feb 2014 08:14:22 -0700
Message-ID: <00e801cf3497$c37255f0$4a5701d0$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:60604 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbaB1POY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 10:14:24 -0500
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I found a thread from June 2012 (subject matches this email) discussing the
addition of parameters to manually tune the delayed TCP ACK parameters, and
add new TCP socket options for application specific tuning. The patch in
question would multiply the receive mss by some constant exposed in /proc.
We have experimented with a similar approach and found significant
improvements in performance when asymmetric links are utilized; specifically
where the hardware is limited in egress packets/sec (but not raw bandwidth).
As an example, in one test we saw a 100% improvement when doing rcv_mss*4.

You had responded to the original patch by stating that you are
fundamentally opposed to the feature. I'm trying to understand specifically
what your objections are. Checking tcp_measure_rcv_mss() current
implementation(as of 3.10),  I do not see any way for rcv_mss to grow beyond
the largest received skb length. 

Thanks,
Harout

--
Harout Hedeshian

Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by
The Linux Foundation
