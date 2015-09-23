From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 10:08:07 +0200
Message-ID: <20150923080807.GA29680@pox.localdomain>
References: <cover.1442936392.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:32863 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbbIWIIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 04:08:10 -0400
Received: by wiclk2 with SMTP id lk2so226990416wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 01:08:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1442936392.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/15 at 06:12pm, Jiri Benc wrote:
> One of the selling points of lwtunnel was the ability to specify the tunnel
> destination using routes. However, this doesn't really work currently, as
> ARP and ndisc replies are not handled correctly. ARP and ndisc replies won't
> have tunnel metadata attached, thus they will be sent out with the default
> parameters or not sent at all, either way never reaching the requester.

Note that ARP is not strictly required in most cases where this form of
encapsulation is used. In particular any kind of broadcasting is very
undesirable for obvious reasons ;-)

The matrix which maps overlay addresses to tunnel endpoint and tunnel id
would normally also contain the MAC address of the virtual endpoint or a
dummy MAC if it's a L3 only endpoint (which is what you want to go for
these days) so you would typically answer the ARP requests locally or just
fill the neighbour cache yourself.

However, I very much agree that we should make this work since it eases
use.

> Most of the egress tunnel parameters can be inferred from the ingress
> metada. The only and important exception is UDP ports. This patchset infers
> the egress data from the ingress data and disallow settings of UDP ports in
> tunnel routes. If there's a need for different UDP ports, a new interface
> needs to be created for each port combination. Note that it's still possible
> to specify the UDP ports to use, it just needs to be done while creating the
> vxlan/geneve interface.

I would assume that dst.tp_dst = src.tp_dst would work well in practice.
The port number should be standardized anyway and would only differ to
support non compatible flavours of VXLAN.

I don't mind putting this restriction on though.
