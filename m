From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 14:14:05 +0200
Message-ID: <1444824845.2190190.409937049.5F844219@webmail.messagingengine.com>
References: <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
 <561E29A3.9080101@6wind.com>
 <1444820621.2175377.409880265.37A31E2D@webmail.messagingengine.com>
 <20151014.051814.801287755321309990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org, hannes@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52502 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751478AbbJNMOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:14:06 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 62A5B200AA
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 08:14:05 -0400 (EDT)
In-Reply-To: <20151014.051814.801287755321309990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Oct 14, 2015, at 14:18, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 14 Oct 2015 13:03:41 +0200
> > The difference is that people upgrade (in case of fedora they get a
> > .rpmnew file) or install a distribution and don't wonder or have
> > assumptions about old behavior. In case companies integrate kernel in
> > products/appliances without a way to manage those sysctls we cannot
> > simply change them as this would break assumptions for them. I think
> > those are two different cases.
> 
> The thing that is similar is that people set rp_filter inappropriately
> (no end host should have that knob enabled, ever, it's totally
> unnecesary).  And the risk here is similar, distribution X will set it
> so Y will say "we probably should set it too even though we really
> don't understand it fully".
> 
> I really hate situations like this.

I can bring up the rp_filter setting, too. It currently gets
unconditional set to strict mode in systemd on all interfaces.

The question is, if we should care about people enabling forwarding by
simply toggling the sysctl forwarding knob? Essentially in the kernel we
could provide two sysctl knobs, one for forwarding and one for local
reception. So people following the guidelines how to enable forwarding
could automatically have rp_filter enabled while host mode does not
because we leave  the forwarding rp_filter setting enabled. This at the
same time seems unnecessary complex and maybe we should simply talk to
distributions. ;)

What do you think?

Bye,
Hannes
