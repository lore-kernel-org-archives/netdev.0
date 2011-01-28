From: Steve Dobbelstein <steved@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Fri, 28 Jan 2011 12:29:37 -0600
Message-ID: <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>	 <20110126151700.GA14113@redhat.com>
	 <1296153874.1640.27.camel@localhost.localdomain>	 <20110127190031.GC5228@redhat.com>
	 <1296155340.1640.34.camel@localhost.localdomain>	 <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>	 <20110127200548.GE5228@redhat.com> <1296159305.1640.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org
To: mashirle@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:60382 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009Ab1A1S3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 13:29:44 -0500
In-Reply-To: <1296159305.1640.50.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mashirle@linux.vnet.ibm.com wrote on 01/27/2011 02:15:05 PM:

> On Thu, 2011-01-27 at 22:05 +0200, Michael S. Tsirkin wrote:
> > One simple theory is that guest net stack became faster
> > and so the host can't keep up.
>
> Yes, that's what I think here. Some qdisc code has been changed
> recently.

I ran a test with txqueuelen set to 128, instead of the default of 1000, in
the guest in an attempt to slow down the guest transmits.  The change had
no effect on the throughput nor on the CPU usage.

On the other hand, I ran some tests with different CPU pinnings and
with/without hyperthreading enabled.  Here is a summary of the results.

Pinning configuration 1:  pin the VCPUs and pin the vhost thread to one of
the VCPU CPUs
Pinning configuration 2:  pin the VCPUs and pin the vhost thread to a
separate CPU on the same socket
Pinning configuration 3:  pin the VCPUs and pin the vhost thread to a
separate CPU a different socket

HT   Pinning   Throughput  CPU
Yes  config 1  - 40%       - 40%
Yes  config 2  - 37%       - 35%
Yes  config 3  - 37%       - 36%
No   none         0%       -  5%
No   config 1  - 41%       - 43%
No   config 2  + 32%       -  4%
No   config 3  + 34%       +  9%

Pinning the vhost thread to the same CPU as a guest VCPU hurts performance.
Turning off hyperthreading and pinning the VPUS and vhost thread to
separate CPUs significantly improves performance, getting it into the
competitive range with other hypervisors.

Steve D.

