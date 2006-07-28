From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 28 Jul 2006 09:47:05 +0400
Message-ID: <20060728054704.GD11210@2ka.mipt.ru>
References: <20060727165121.GA6637@2ka.mipt.ru> <20060727205651.GA29953@ms2.inr.ac.ru> <20060728051723.GA11210@2ka.mipt.ru> <20060727.223400.97292695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kuznet@ms2.inr.ac.ru, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:8120 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751975AbWG1Fr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 01:47:28 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.223400.97292695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2006 at 10:34:00PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 28 Jul 2006 09:17:25 +0400
> 
> > What would you expect from non-preemptible kernel? Hard lockup, no acks,
> > no soft irqs.
> 
> Why does pressing Ctrl-Z on the user process stop kernel soft irq
> processing?

I do not know, why Alexey decided that Ctrl-Z was ever pressed.
I'm saying about the case when keventd ate 100% of CPU, but stack worked
with (very) long delays. Obviously userspace was unresponsible and no
data arrived there.
It is an analogy that posponed softirq work does not destroy connections
as long as process context protocol processing with delays.
User does not get it's data, so no need to send an ack. And if it is
impossible to get that data at all, user should not care that sending
side does not see acks. When user is capable to get that data, it starts
to acknowledge.

-- 
	Evgeniy Polyakov
