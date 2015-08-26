From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Thu, 27 Aug 2015 00:13:30 +0200
Message-ID: <20150826221330.GB31292@pox.localdomain>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
 <20150823.165103.2104601245219561984.davem@davemloft.net>
 <20150826181926.0444240f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35001 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbbHZWNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:13:32 -0400
Received: by wicne3 with SMTP id ne3so57670484wic.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:13:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150826181926.0444240f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/15 at 06:19pm, Jiri Benc wrote:
> might be a noise. However, there's definitely room for performance
> improvement here, the lwtunnel vxlan throughput is at about ~40% of the
> non-vxlan throughput. I did not spend too much time on analyzing this, yet,
> but it's clear the dst_entry layout is not our biggest concern here.

I'm currently working on reducing the overhead for VXLAN and Gre and
effectively Geneve once Pravin's work is in. The main disadvantage
of lwt based flow tunneling is the additional fib_lookup() performed
for each packet. It seems tempting to cache the tunnel endpoint dst in
the lwt state of the overlay route. It will usually point to the same
dst for every packet. The cache behaviour if dependant on no fib rules
are and the route is a single nexthop route.

Did you test with a card that features UDP encapsulation offloads?
