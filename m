From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 6 May 2009 16:06:30 -0700
Message-ID: <4A0217F6.7060005@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>	<1241586309-12112-5-git-send-email-dhananjay@netxen.com> <20090506.153714.122287244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:12927 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752782AbZEFXGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 19:06:32 -0400
In-Reply-To: <20090506.153714.122287244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reason for RSS was to distribute the ingress traffic
to different CPUs. At 10Gbps, without RSS, one CPU was
saturating, acting as bottleneck. I can do 1Gbps with
only one CPU only 50% saturated, this to on a low end
server.

The fallout is more msix vectors being consumed for RSS,
when they don't really bring any performance gain.

Since NetXen has single driver, unlike others, it needs
to be dealt based on NIC board type.

-Dhananjay

David Miller wrote:
> From: Dhananjay Phadke <dhananjay@netxen.com>
> Date: Tue,  5 May 2009 22:05:09 -0700
> 
>> There's no advantage of receive side scaling on GbE ports, so
>> restrict rss support to 10GbE ports.
>>
>> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> 
> This is your opinion.  And even if it is more than opinion,
> you give zero technical arguments in your commit message so
> we can see why this should be done.
> 
> Tell that opinion to the person with 10 netxen cards in their
> machine running at full tilt.
> 
> Tell that opinion to the person with extremely complicated and
> cpu intensive netfilter and routing rules in use.
> 
> I'm not applying this patch.
