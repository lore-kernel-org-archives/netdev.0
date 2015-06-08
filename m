From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Tue, 9 Jun 2015 00:58:43 +0200
Message-ID: <20150608225843.GA4602@pox.localdomain>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com>
 <20150605091441.GA11896@pox.localdomain>
 <5571AF28.8000009@cumulusnetworks.com>
 <5571BF90.2070304@brocade.com>
 <557260E0.9060500@cumulusnetworks.com>
 <20150608123302.GA3634@pox.localdomain>
 <5575B207.4040900@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33320 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932249AbbFHW6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:58:47 -0400
Received: by wiwd19 with SMTP id d19so1782170wiw.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 15:58:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5575B207.4040900@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/15 at 08:17am, roopa wrote:
> ack, that sounds intuitive.
> With RTA_ENCAP and the mpls examples i was using it looks something like the
> below for (1)
> ip route add 10.1.1.0/30 encap mpls 200 via 10.1.1.1 dev eth0
> 
> The tunnel dst is parsed and understood by the light weight tunnel driver,
> which I think will
> end up having to do the lookup (needs more thought)...for (2) and (3).

I think we only want to perform the nested fib lookup if no dev
is specified. If a tunnel device is specified, that device will
do the fib lookup and can cache the route in the encap socket.

> >Your nexthop implementation seemed more correct based on the chunks
> >I went through. Can we combine the two series and make the RTA_OIF
> >in the nexthop optional if an RTA_ENCAP was provided and provide a
> >route lookup instead?
> 
> yes, we can do that.
>  Robert can correct me if i misunderstood, both our patches had similar code
> to handle RTA_ENCAP.
> Only difference was in the way we stored the encaped data, mine was a
> pointer to tunnel state and his was embedded in fib_nh. His patch today
> assumes there is a tunnel device.
> And mine assumes the output device is specified in the ipv4 fib route.

I'll immediately ACK any series that supports both models and rebase
my patches on top of it. I think we are on the right track overall.

> I am trying to get my code on github to collaborate better. Stay tuned
> (hopefully end of day today).

Cool

> While we are on this conversation, Though the code already supports nested
> attributes (with the example robert showed), I introduced explicit nested
> attributes for mpls in my version,
> and it seemed like it is better to introduce two attributes RTA_ENCAP_TYPE
> and RTA_ENCAP and
> type determines the nested policy for RTA_ENCAP
> RTA_ENCAP_TYPE /* MPLS, VXLAN etc */

+1
