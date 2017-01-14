From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH v2 net-next] Introduce a sysctl that modifies the value
 of PROT_SOCK.
Date: Fri, 13 Jan 2017 16:11:38 -0800
Message-ID: <20170114001138.GC3094@templeofstupid.com>
References: <20161231125505.7f0c7dff@xeon-e3>
 <20170112065225.GB2345@templeofstupid.com>
 <1484231997.15816.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:47106 "EHLO
        homiemail-a43.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750713AbdANALk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:11:40 -0500
Received: from homiemail-a43.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a43.g.dreamhost.com (Postfix) with ESMTP id 93B5D6002C06
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:11:39 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a43.g.dreamhost.com (Postfix) with ESMTPSA id 654FC6002972
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:11:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484231997.15816.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 06:39:57AM -0800, Eric Dumazet wrote:
> On Wed, 2017-01-11 at 22:52 -0800, Krister Johansen wrote:
> > Add net.ipv4.ip_unprotected_port_start, which is a per namespace sysctl
> > that denotes the first unprotected inet port in the namespace.  To
> > disable all protected ports set this to zero.  It also checks for
> > overlap with the local port range.  The protected and local range may
> > not overlap.
> > 
> > The use case for this change is to allow containerized processes to bind
> > to priviliged ports, but prevent them from ever being allowed to modify
> > their container's network configuration.  The latter is accomplished by
> > ensuring that the network namespace is not a child of the user
> > namespace.  This modification was needed to allow the container manager
> > to disable a namespace's priviliged port restrictions without exposing
> > control of the network namespace to processes in the user namespace.
> > 
> > Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> > ---
> >  include/net/ip.h               | 10 +++++++++
> >  include/net/netns/ipv4.h       |  1 +
> >  net/ipv4/af_inet.c             |  5 ++++-
> >  net/ipv4/sysctl_net_ipv4.c     | 50 +++++++++++++++++++++++++++++++++++++++++-
> >  net/ipv6/af_inet6.c            |  3 ++-
> >  net/netfilter/ipvs/ip_vs_ctl.c |  7 +++---
> >  net/sctp/socket.c              | 10 +++++----
> >  security/selinux/hooks.c       |  3 ++-
> 
> Adding a new sysctl without documentation is generally not accepted.
> 
> Please take a look at Documentation/networking/ip-sysctl.txt

Thanks for catching this.  I'll add an entry to the documentation.

> BTW, sticking to 'unprivileged' ports might be better than 'unprotected'
> which is vague.

I don't have a strong preference about the naming.  I'd be happy to
change it to 'unprivileged' instead.

-K
