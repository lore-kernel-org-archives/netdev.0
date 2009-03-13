From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Fri, 13 Mar 2009 14:01:07 -0700
Message-ID: <65634d660903131401v24d0b5aarec36ad95220ba201@mail.gmail.com>
References: <1236866906.3221.11.camel@achroite>
	 <1236926602.2567.528.camel@ymzhang>
	 <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
	 <20090313.115137.254924980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51955 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbZCMVBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 17:01:31 -0400
In-Reply-To: <20090313.115137.254924980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 11:51 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 13 Mar 2009 10:06:56 -0700
>
> > You'll definitely want to look at the hardware provided hash.  We've
> > been using a 10G NIC which provides a Toeplitz hash (the one defined
> > by Microsoft) and a software RSS-like capability to move packets from
> > an interrupting CPU to another for processing.  The hash could be used
> > to index to a set of CPUs, but we also use the hash as a connection
> > identifier to key into a lookup table to steer packets to the CPU
> > where the application is running based on the running CPU of the last
> > recvmsg.  Using the device provided hash in this manner is a HUGE win,
> > as opposed to taking cache misses to get 4-tuple from packet itself to
> > compute a hash.  I posted some patches a while back on our work if
> > you're interested.
>
> I never understood this.
>
> If you don't let the APIC move the interrupt around, the individual
> MSI-X interrupts will steer packets to individual specific CPUS and as
> a result the scheduler will migrate tasks over to those cpus since the
> wakeup events keep occuring there.

We are trying to follow the decisions scheduler as opposed to leading
it.  This works on very loaded systems, with applications binding to
cpusets, with threads that are receiving on multiple sockets.  I
suppose it might be compelling if a NIC could steer packets per flow,
instead of by a hash...
