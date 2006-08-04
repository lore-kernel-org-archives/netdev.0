From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] driver adjusts qlen, increases CPU
Date: Fri, 04 Aug 2006 11:43:05 -0700
Message-ID: <44D39539.5040805@hp.com>
References: <Pine.WNT.4.63.0605100905150.1804@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:30407 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751418AbWHDSnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 14:43:07 -0400
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0605100905150.1804@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> So we've recently put a bit of code in our e1000 driver to decrease the 
> qlen based on the speed of the link.
> 
> On the surface it seems like a great idea.  A driver knows when the link 
> speed changed, and having a 1000 packet deep queue (the default for most 
> kernels now) on top of a 100Mb/s link (or 10Mb/s worst case for us) makes 
> for a *lot* of latency if many packets are queued up in the qdisc.
> 
> Problem we've seen is that setting this shorter queue causes a large spike 
> in cpu when transmitting using UDP:
> 
> 100Mb/s link
> txqueuelen: 1000 Throughput: 92.44 CPU: 5.00
> txqueuelen: 100 Throughput: 93.80 CPU: 61.59
> 
> Is this expected? any comments?

Triggering intra-stack flow-control perhaps?  Perhaps 10X more often 
than before if the queue is 1/10th what it was before?

Out of curiousity, how does the UDP socket's SO_SNDBUF compare to the 
queue depth?

rick jones
