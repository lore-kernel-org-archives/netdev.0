From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v2 5/6] gtp: add socket to pdp context
Date: Mon, 6 Feb 2017 15:04:18 +0100
Message-ID: <20170206140418.dwiofucns5eolgel@nataraja>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-6-aschultz@tpip.net>
 <20170202135656.GA23901@salvia>
 <858150010.730228.1486044775198.JavaMail.zimbra@tpip.net>
 <20170202142842.GA19643@salvia>
 <249401941.730762.1486046287023.JavaMail.zimbra@tpip.net>
 <20170202144606.GA19992@salvia>
 <2083605423.731432.1486048043458.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58525 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753242AbdBFOEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:04:39 -0500
Content-Disposition: inline
In-Reply-To: <2083605423.731432.1486048043458.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

On Thu, Feb 02, 2017 at 04:07:23PM +0100, Andreas Schultz wrote:
> ----- On Feb 2, 2017, at 3:46 PM, pablo pablo@netfilter.org wrote:
> > On Thu, Feb 02, 2017 at 03:38:07PM +0100, Andreas Schultz wrote:
> >> ----- On Feb 2, 2017, at 3:28 PM, pablo pablo@netfilter.org wrote:
> >> > I suggest you just call kfree_rcu() from 4/6.
> >> > 
> >> > Regarding holding socket reference, see my comment for patch 1/6.
> >> 
> >> This is going to be a problem at this stage of the changes.
> >> 
> >> The final goal is to have a reference from the socket to the pdp context.
> > 
> > Is this just a cleanup? Or you need this sk caching for some follow up
> > work?
> 
> It's not caching, the plan is to completely remove the socket from the
> GTP netdevice (as far as that is possible without breaking the existing API).

I agree this is the way to go.  When I originally thought about the GTP
kernel tunneling module early on, I was not aware of the fact that
operators actually in practise run multiple "virtual GGSNs" on one IP
address/port.  From a pure technical point of view you would say "why
bother"?  They could just use separate IP addresses for each of them.
However, the reailty is that each new IP address that an operator uses
for a GGSN results in paper forms required to be exchanged between this
operator and all his roming partners, followed-up by manual
re-configuration of the policies on all of those roaming partners.  This
is time-consuming and error-prone, but hey, it's how the procedures
between GSMA members seem to work ;)

> A GGSN or PGW can serve multiple APN's on the same GTP-U socket. Those APN's
> can have overlapping IP address ranges. The only sensible way to handle
> this, is to have a netdevice per APN. This breaks the current 1:1 relation
> between sockets and netdevices.

Indeed.  So the question is how to do this best and how to keep
backwards compatibility of the netlink interface.  I don't claim to have
answers to that, sorry.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
