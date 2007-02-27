From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 stable in 2.6.12-rc1 (but still performance problem)...
Date: Tue, 27 Feb 2007 09:56:44 -0800
Message-ID: <20070227095644.46d24054@freekitty>
References: <6278d2220702270331k7b91017ds4c0eb0be4e4e9697@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42944 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbXB0R4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 12:56:49 -0500
In-Reply-To: <6278d2220702270331k7b91017ds4c0eb0be4e4e9697@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Feb 2007 11:31:58 +0000
"Daniel J Blueman" <daniel.blueman@gmail.com> wrote:

> Hi Stephen,
> 
> 2.6.21-rc1 is the first kernel where my SysKonnect Yukon 2 hardware
> with the sky2 v1.13 driver is stable under moderate load. Before a few
> GBs of data going over my GigE network quickly with NFSv4 would cause
> transmit timeouts previously, but now fine.
> 
> I am still observing a performance problem - feels like a wmb() or
> some buffer flushing is missing somewhere - disabling processor clock
> scaling reduces the problem a bit, but does not eliminate it.

That seems odd, if it was a missing barrier you would see data corruption.
Are there checksum errors?

You might be seeing hardware flow control. Look at ethtool -S eth0 output.
Previously, transmit flow control was broken

> What are your preferred way of checking performance? I think that the
> TCP send window can grow enough even if ACKs are delayed due to this
> problem, such that TCP does not immediately demonstrate this issue. I
> could restrict the window scaling factor, so it would be bound by the
> data->ACK round-trip latency, which /should/ be low, but I've been
> observing it higher. Maybe I try this.

iperf is easiest.

> I'll see what I get with iperf UDP also, since this shows min, max,
> avg UDP packet latency IIRC.
> 
> Thanks for your great work so far though!
>   Dan


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
