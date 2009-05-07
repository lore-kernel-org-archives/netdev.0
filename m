From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 6 May 2009 17:08:06 -0700
Message-ID: <4A022666.4060906@netxen.com>
References: <1241586309-12112-5-git-send-email-dhananjay@netxen.com>	<20090506.153714.122287244.davem@davemloft.net>	<4A0217F6.7060005@netxen.com> <20090506.163142.112368323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:14400 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753353AbZEGAIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 20:08:07 -0400
In-Reply-To: <20090506.163142.112368323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller wrote:
> Thanks for ignoring my email.
> 
> I'll say it again, maybe you'll listen this time.
> 
> If a user has very cpu intensive netfilter or routing
> rules installed, the RSS flow seperation to different
> CPUs can help even at 1GB speeds.
> 
> Therefore, your change will introduce performance regressions.

I got your point, but there's another reason I have put
forward. With four (not even 10) 4-port netxen NICs
installed, they will consume 64 or more msi-x vectors.
When all this for only 1Gbps per port, restricted by
physical media speed.

This is only per port accounting, when it has to be
per pci function. The virtual NICs have more than one
pci function per physical port (=> 32 vectors per card).

There are other ways to balance the load, like moving
tx ring clean up to separate (one) msi-x vector.

I do see a reason for conserving msix vectors, unless
they are bringing performance gain.

Middle ground can be using 2 vectors per pci func, instead
of 4 (which has been tested to benefit 10Gbps NICs).

Call it my opinion, but may be it's necessary if system has
limited msi vectors.

-Dhananjay
