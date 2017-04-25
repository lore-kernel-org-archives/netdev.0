From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC 0/4] xdp: use netlink extended ACK reporting
Date: Tue, 25 Apr 2017 14:05:28 -0700
Message-ID: <20170425140528.6ba6479b@cakuba.netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
        <2fbd12c0-dfed-c8df-8c74-1686565168ab@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        johannes@sipsolutions.net, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, oss-drivers@netronome.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:58415 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1947587AbdDYVFw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 17:05:52 -0400
In-Reply-To: <2fbd12c0-dfed-c8df-8c74-1686565168ab@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Apr 2017 08:53:35 -0600, David Ahern wrote:
> On 4/25/17 2:06 AM, Jakub Kicinski wrote:
> 
> > Also - is anyone working on adding proper extack support to iproute2?
> > The code I have right now is a bit of a hack...  
> 
> This is what I have done:
>     https://github.com/dsahern/iproute2/commits/ext-ack
> 
> Basically, added the parsing code and then a new rtnl_talk_extack
> function that takes a callback to invoke with the extack data. The last
> patch (of 3) purposely breaks ip set link mtu -- sending the mtu as a
> u16 rather than a u32 just to work on the plumbing for parsing the
> returned message:
> 
> $ ip li set dummy1 mtu 1490
> Error with rtnetlink attribute IFLA_MTU
> 
> If an errmsg is returned it is printed as well.

Great, that's much better than what I have.  It will make the XDP patch
for iproute2 pretty trivial :)
