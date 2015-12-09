From: Thomas Graf <tgraf@suug.ch>
Subject: Re: forwarding of ipv4 link local addresses
Date: Wed, 9 Dec 2015 14:44:16 +0100
Message-ID: <20151209134416.GB11201@pox.localdomain>
References: <565E12BE.90006@cumulusnetworks.com>
 <20151203.143531.282555789343463670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34183 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbbLINoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 08:44:19 -0500
Received: by wmvv187 with SMTP id v187so262378330wmv.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 05:44:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151203.143531.282555789343463670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/15 at 02:35pm, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 1 Dec 2015 13:35:58 -0800
> 
> > RFC 3927 states that packets from/to IPv4 link-local addresses
> > (169.254/16) should not be forwarded, yet the Linux networking stack
> > happily forwards them. Before sending in a patch I wanted to inquire
> > if this behavior is intentional.
> 
> It probably won't break anything if we prohibit this, so sure send
> a patch.

I don't have the full email context so apologies if this is not
relevant. The RFC states that such addresses should not be forwarded
_beyond the local link_. So as long as you are not breaking forwarding
of these addresses on the local host, I'm perfectly fine.

I bring this up specifically because of:

commit d0daebc3d622f95db181601cb0c4a0781f74f758
Author: Thomas Graf <tgraf@suug.ch>
Date:   Tue Jun 12 00:44:01 2012 +0000

    ipv4: Add interface option to enable routing of 127.0.0.0/8
    
    Routing of 127/8 is tradtionally forbidden, we consider
    packets from that address block martian when routing and do
    not process corresponding ARP requests.

    [...]

This feature is being used by a popular PaaS which leverages the
127/8 address space locally without polluting an entire routeable
address space.
