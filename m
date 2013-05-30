From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC - VXLAN port range facility
Date: Thu, 30 May 2013 20:33:07 +0100
Message-ID: <1369942387.2414.24.camel@bwh-desktop.uk.level5networks.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
	 <20130530094141.7c125947@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29291 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759603Ab3E3TdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 15:33:12 -0400
In-Reply-To: <20130530094141.7c125947@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 09:41 -0700, Stephen Hemminger wrote:
> On Thu, 30 May 2013 08:40:56 -0400
> David Stevens <dlstevens@us.ibm.com> wrote:
[...]
> > I think a port ranges may be useful in the context of a small number (say 
> > 10)
> > of ports that you are actually bound to, so then as part of multi-port 
> > binding
> > support. But then a default range of 32K-61K is too large. It then, at 
> > least,
> > has the potential to manage ICMP errors triggered by VXLAN.
> 
> Port ranges are critical to retaining scaling in multi-path infrastructure.
> Otherwise all traffic will arrive on a single queue in NIC.
[...]

If you include UDP port numbers in the flow hash, a UDP flow with a
mixture of fragmented and unfragmented datagrams is likely to be split
between two queues.  Most multiqueue NICs follow the Microsoft RSS spec
which says to include the port numbers in the flow hash for TCP only.
Some hardware and drivers provide the option to override the hashing
behaviour for UDP or to steer by port number, but perhaps it would be
more portable to support the use of a range of IP addresses?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
