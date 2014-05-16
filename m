From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 07:23:23 -0700
Message-ID: <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
	 <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53761286.2040505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:48891 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbaEPOX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:23:26 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so2671401pbb.35
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 07:23:25 -0700 (PDT)
In-Reply-To: <53761286.2040505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 06:28 -0700, Ben Greear wrote:
> 
> On 05/16/2014 06:16 AM, Eric Dumazet wrote:
> > On Fri, 2014-05-16 at 12:34 +0200, Thomas Graf wrote:
> >> The memset() on the packet data is expensive and severely limiting
> >> the pps throughput for large frame sizes.
> >>
> >> Considering that pktgen requires root privileges to run it is safe
> >> to introduce an option to optionally avoid the memset() and leave
> >> the packet data uninitialized.
> >>
> >> VM test results, 2 VCPU, 2 threads, pkt_size=9K:
> >>
> >>      12.44%  -11.15%  [kernel.kallsyms]   [k] memset
> >>       4.84%   +1.58%  [kernel.kallsyms]   [k] get_page_from_freelist
> >>
> >> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >> ---
> >>   Documentation/networking/pktgen.txt |  3 +++
> >>   net/core/pktgen.c                   | 16 ++++++++++++++--
> >>   2 files changed, 17 insertions(+), 2 deletions(-)
> >
> > We do not want to leak content of memory, even if 'root' is willing to.
> >
> > Sorry, you need to do something else if you really care.
> 
> Is there currently no other way for root to grab memory contents and
> send them over the network?
> 
> I mean, it could load it's own module and do bad things if nothing else?

pktgen has already a way to send fragments which are not memset for
every packet. We share a 'zero' page for that.

So only headers need to be really built for each packet.
