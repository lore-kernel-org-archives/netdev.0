From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Subject: Re: [omega-g1:11110] Re: [PATCH] net: configurable sysctl parameter
 "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Fri, 09 Sep 2011 10:33:58 +0900
Message-ID: <4E696D06.3000003@ctc-g.co.jp>
References: <4E51A3F0.5010500@ctc-g.co.jp>
 <20110822.113544.28950168095176936.davem@davemloft.net>
 <4E55D3C2.40308@ctc-g.co.jp>
 <20110824.220016.781758659534965980.davem@davemloft.net>
Reply-To: jun.kondo@ctc-g.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.ctc-g.co.jp ([131.248.58.1]:63632 "EHLO mx.ctc.ctc-g.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757637Ab1IIBeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 21:34:13 -0400
In-reply-to: <20110824.220016.781758659534965980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The client of this system is cellular phone, and the
status of the communication line with a client varies
widely according to its place or congestion situation.

In terms of the line speed, it can be around 9Mbps
when it is fast, but 8kbps when it is slow.

Requirement from customer is to provide stable service
in both situation.

- In normal situation, acquire large default transmission
   buffer value, and ensure high throughput from the
   beginning of tcp connection

- On the other hand, even when the connection has low
   throughput, such as low rate streaming, transmit data
   without timeout

However, when the throughput is low, it takes much time
for the transmission buffer to be freed, and timeout
will occur during that period.

Of course, the connection will not be disconnected when
the timeout of application is extended, but end user
would not wait patiently as long as 1 minute.
Therefore, we do not want to extend the timeout value.

By making the threshold, which makes write possible after
the buffer is blocked once, configurable, and set it to a
small value, it will be possible to return data to client
without making timeout occur.

So, we think the issue can be solved with this
modification.
