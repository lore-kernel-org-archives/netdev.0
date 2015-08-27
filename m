From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel state
Date: Thu, 27 Aug 2015 12:47:52 -0700
Message-ID: <CALx6S36+e7O_n+UKvFO89goKoE2QV2EDa5CrzEU9eAoD13e-EQ@mail.gmail.com>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
	<20150823.165103.2104601245219561984.davem@davemloft.net>
	<20150826181926.0444240f@griffin>
	<20150826221330.GB31292@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38173 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbH0Trx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 15:47:53 -0400
Received: by igvb3 with SMTP id b3so1913148igv.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 12:47:53 -0700 (PDT)
In-Reply-To: <20150826221330.GB31292@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 3:13 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/26/15 at 06:19pm, Jiri Benc wrote:
>> might be a noise. However, there's definitely room for performance
>> improvement here, the lwtunnel vxlan throughput is at about ~40% of the
>> non-vxlan throughput. I did not spend too much time on analyzing this, yet,
>> but it's clear the dst_entry layout is not our biggest concern here.
>
> I'm currently working on reducing the overhead for VXLAN and Gre and
> effectively Geneve once Pravin's work is in. The main disadvantage
> of lwt based flow tunneling is the additional fib_lookup() performed
> for each packet. It seems tempting to cache the tunnel endpoint dst in
> the lwt state of the overlay route. It will usually point to the same
> dst for every packet. The cache behaviour if dependant on no fib rules
> are and the route is a single nexthop route.
>
Or set nexthop appropriately. This what we do for ILA. Works great
without any other dst references, but might put to much weight in the
administrator to configure nexthop per encapsulating destination.

Tom

> Did you test with a card that features UDP encapsulation offloads?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
