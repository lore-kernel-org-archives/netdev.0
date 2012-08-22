From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Best way to set kernel thread affinity for handling a socket?
Date: Wed, 22 Aug 2012 17:21:33 +0100
Message-ID: <1345652493.2709.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32541 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757776Ab2HVQVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 12:21:37 -0400
In-Reply-To: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 09:10 -0700, Roland Dreier wrote:
> Hi everyone,
> 
> Let's say I have kernel code that's sitting in a loop doing
> kernel_accept() on a TCP socket.  As each connection comes in, it
> forks off a kernel thread to deal with that socket.
> 
> If I have a modern NIC with RSS and multiple queues, each TCP flow is
> going to be steered to one queue, which is probably bound to one CPU.
> So when I fork off that kernel thread, I'd like to bind it to the CPU
> where its NIC queues are going to be processed.  My question is, how
> do I find out which CPU that is?  Is there anything in the new socket
> structure I get back from kernel_accept() that I can look at to know
> which CPU the packets came in on?

With RFS we try to do the reverse: move the packets to match the socket
user.   But it's not (yet) turned on by default.  See
Documentation/networking/scaling.txt

> I'm thinking about this in the context of the kernel's iSCSI target
> code (drivers/target/iscsi), which creates threads to handle each
> iSCSI connection and sets their CPU affinity pretty much randomly
> (well, based on some "thread id", cf iscsit_thread_get_cpumask()).

Why set the affinity at all?

> And with a modern NIC, this leads to packets being received on one CPU
> but the data being consumed on another CPU, all the time, which is
> obviously far from optimal.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
