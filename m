From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: sky2 stable in 2.6.12-rc1 (but still performance problem)...
Date: Tue, 27 Feb 2007 11:31:58 +0000
Message-ID: <6278d2220702270331k7b91017ds4c0eb0be4e4e9697@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:64801 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933045AbXB0Lb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 06:31:59 -0500
Received: by nf-out-0910.google.com with SMTP id o25so149015nfa
        for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 03:31:58 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

2.6.21-rc1 is the first kernel where my SysKonnect Yukon 2 hardware
with the sky2 v1.13 driver is stable under moderate load. Before a few
GBs of data going over my GigE network quickly with NFSv4 would cause
transmit timeouts previously, but now fine.

I am still observing a performance problem - feels like a wmb() or
some buffer flushing is missing somewhere - disabling processor clock
scaling reduces the problem a bit, but does not eliminate it.

What are your preferred way of checking performance? I think that the
TCP send window can grow enough even if ACKs are delayed due to this
problem, such that TCP does not immediately demonstrate this issue. I
could restrict the window scaling factor, so it would be bound by the
data->ACK round-trip latency, which /should/ be low, but I've been
observing it higher. Maybe I try this.

I'll see what I get with iperf UDP also, since this shows min, max,
avg UDP packet latency IIRC.

Thanks for your great work so far though!
  Dan
-- 
Daniel J Blueman
