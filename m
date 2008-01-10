From: Karsten Keil <kkeil@suse.de>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 12:29:13 +0100
Message-ID: <20080110112913.GB5065@pingi.kke.suse.de>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080109.153212.144388472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41829 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748AbYAJL3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 06:29:15 -0500
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 125D72FA28
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 12:29:14 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20080109.153212.144388472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 03:32:12PM -0800, David Miller wrote:
> From: Karsten Keil <kkeil@suse.de>
> Date: Wed, 9 Jan 2008 16:36:56 +0100
> 
> >    If the address is a link-local address formed from an interface
> >    identifier based on the hardware address, which is supposed to be
> >    uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
> >    operation on the interface SHOULD be disabled.  By disabling IP
> >    operation, the node will then:
> > 
> >    -  not send any IP packets from the interface,
> > 
> >    -  silently drop any IP packets received on the interface, and
> > 
> >    -  not forward any IP packets to the interface (when acting as a
> >       router or processing a packet with a Routing header).
> 
> I question any RFC mandate that shuts down IP communication on a node
> because of packets received from remote systems.
> 
> If the TAHI test can trigger this, so can a compromised system on your
> network and won't that be fun? :-)

I agree, but on the other side, a interface with a real duplicate HW address
sending packets on the network can also cause very serious problems, and
maybe is not so easy to detect as  a system where the interface never come
up because of this. So maybe it makes sense to implement it as option, not
as default.
And the DOS scenario is already here, also without disabling IP completely,
since you can deny any IPv6 address assignments with faked DAD pakets.

-- 
Karsten Keil
SuSE Labs
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
