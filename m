From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 06 Aug 2013 21:25:30 +0300
Message-ID: <52013F9A.9020005@linux.intel.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com> <5200A8BC.4010402@linux.intel.com> <20130806180806.GA8993@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60901 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756371Ab3HFSZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 14:25:42 -0400
In-Reply-To: <20130806180806.GA8993@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2013 21:08, Shawn Bohrer wrote:
> On Tue, Aug 06, 2013 at 10:41:48AM +0300, Eliezer Tamir wrote:
>> For multicast, it is possible that incoming packets to come from more
>> than one port (and therefore more than one queue).
>> I'm not sure how we could handle that, but what we have today won't do
>> well for that use-case.
>  
> It is unclear to me exactly what happens in this case.  With my simple
> patch I'm assuming it will spin on the receive queue that received the
> last packet for that socket.  What happens when a packet arrives on a
> different receive queue than the one we were spinning on? I assume it
> is still delivered but perhaps the spinning process won't get it until
> the spinning time expires?  I'm just guessing and haven't attempted to
> figure it out from looking through the code.

What will happen is that the current code will only busy poll on one
queue, sometimes on this one, sometimes on that one.

packets arriving on the other queue will still be serviced but will
suffer the latency of waiting for NAPI to schedule.

So your avg will be better, but your std. dev. much worse and it's
probably not worth it if you really expect two devices to receive
data at the same time.
