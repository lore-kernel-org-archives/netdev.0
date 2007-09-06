From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Thu, 6 Sep 2007 16:37:03 +0100
Message-ID: <20070906163703.4fc12d32@oldman>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	<20070906153700.57a0c448@oldman>
	<46E01D16.5000609@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, davem@davemloft.net,
	jeff@garzik.org, mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44311 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755421AbXIFPhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 11:37:48 -0400
In-Reply-To: <46E01D16.5000609@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 06 Sep 2007 16:30:30 +0100
James Chapman <jchapman@katalix.com> wrote:

> Stephen Hemminger wrote:
> 
> > What about the latency that NAPI imposes? Right now there are certain applications that
> > don't like NAPI because it add several more microseconds, and this may make it worse.
> 
> Latency is something that I think this approach will actually improve, 
> at the expense of additional polling. Or is it the ksoftirqd scheduling 
> latency that you are referring to?

The problem is that you leave interrupts disabled, right. Also you are busy during
idle which kills powersaving and no hz clock.

> > Maybe a per-device flag or tuning parameters (like weight sysfs value)? or some other
> > way to set low-latency values.
> 
> Yes. I'd like to think good defaults could be derived though, perhaps 
> based on settings like CONFIG_PREEMPT, CONFIG_HIGH_RES_TIMER, CONFIG_HZ 
> and maybe even bogomips / nr_cpus.
> 
> -- 
> James Chapman
> Katalix Systems Ltd
> http://www.katalix.com
> Catalysts for your Embedded Linux software development
> 
