From: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Wed, 29 Apr 2009 21:04:36 +0930
Message-ID: <20090429210436.a515465b.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
References: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090428161545.0612476d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:34170 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbZD2Lek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 07:34:40 -0400
In-Reply-To: <20090428161545.0612476d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Thanks for you time.

On Tue, 28 Apr 2009 16:15:45 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Tue, 28 Apr 2009 22:01:43 +0930
> Mark Smith  <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> wrote:
> 
> > Hi,
> > 
> > Following on from my initial ECTP post on the 23rd of April, here is an
> > updated revision.
> > 
> > Changes:
> > 
<snip>

> > 
> > Feedback from some networking and sys admin people I've told about it
> > has been positive - they all agree with the benefit of being able to
> > perform "ping" style testing on an Ethernet segment without requiring
> > IP to be configured.
> > 
> > Any suggestions for improvement would be most appreciated.
> > 
> > Thanks very much,
> > Mark.
> > 
> 
> Why does this have to be in the kernel?  Why not all in user space
> with AF_PACKET?

It doesn't have to be, however I think the same question could be asked
as to why the IPv4, IPv6 and 802.2/LLC echo reply functions are in the
kernel, when they could be implemented in user space too.

Here are the reasons why I think it should be in the kernel:

o  As the Ethernet V2.0 protocol is implemented in the kernel, the
offical Ethernet V2.0 testing function should also be implemented in
the kernel. Making Ethernet layer testing rely on a user space
process makes it less reliable and less universally available as a
specific test of Ethernet link layer connectivity. IIRC, this is the
justification for why IPv4 and IPv6 ICMP echo reply functions are in
operating system kernels rather than as user space processes. 

o  Compared to near equivalent link tesing using IPv4 ping, ECTP doesn't
require any pre-configuration at all.

o  I think it can serve as a "hello world"-like example of basic packet
processing in the kernel. Other protocols that exist in the kernel that
can be used as examples are pretty complicated when compared to ECTP.
To understand their implementations, you need to understand the protocol
well before hand, which can be a fairly time consuming task. As ECTP is
a very simple, single packet format protocol, that has pretty simple
processing, the time investment in understanding it is fairly small -
probably well and truly less than an hour. I think that, combined with
what I hope is a very straight forward and easy to follow
implementation, could help people come quickly up to speed with the
basics of kernel packet processing. It's for this reason that I also 
invested quite a bit of time in providing an overview of the protocol
in the Documentation/networking/ectp.txt file. I think it also could be
a simple to follow example of how to use SKB queues, and how to use the
new high res timers subsystem.

o  It would be another method for testing network stack latency. The
recent udpping testing that is being performed by Christoph Lameter is
testing the Ethernet, IP and UDP layers of the kernel. Using ECTP for
this type of testing isolates the IP and UDP implementations from
influencing the results.

o  It provides more link layer testing capabilities than the 802.2/LLC
TEST function. ECTP supports querying of available ECTP nodes via
broadcast and multicast requests, and testing of paths between
a number of stations. The 802.2/LLC TEST function only supports
request / reply testing between a pair of stations.

Best regards,
Mark.

