From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: netstat not tracking all packets
Date: Thu, 15 Jul 2004 11:17:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40F6A027.5050201@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We just ran into an issue where incoming IP packets were being dropped due to 
socket buffer overflow, but there were no statistics showing it.  Increasing the 
buffer size made the problems go away, but it was frustrating to not have 
accurate statistics.

After a bit of digging, I found the following path:

raw_v4_input
	skb_clone
	raw_rcv(sk, clone)
		raw_rcv_skb


If the socket rx buffer is full raw_rcv_skb then drops the packet without 
incrementing any counters.  There's a FIXME comment in there that looks like its 
been there for two years and counting.

Anyone have a fix for this, or know of other areas where the counters are not 
accurate?

Chris
