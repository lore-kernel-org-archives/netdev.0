From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip maddr: fix filtering by device
Date: Thu, 19 Oct 2017 11:06:58 +0200
Message-ID: <20171019090658.GA21378@orbyte.nwl.cc>
References: <20171019082108.40D7AA0EDF@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Petr Vorel <pvorel@suse.cz>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49574 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751014AbdJSJHA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 05:07:00 -0400
Content-Disposition: inline
In-Reply-To: <20171019082108.40D7AA0EDF@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 10:21:08AM +0200, Michal Kubecek wrote:
> Commit 530903dd9003 ("ip: fix igmp parsing when iface is long") uses
> variable len to keep trailing colon from interface name comparison.  This
> variable is local to loop body but we set it in one pass and use it in
> following one(s) so that we are actually using (pseudo)random length for
> comparison. This became apparent since commit b48a1161f5f9 ("ipmaddr: Avoid
> accessing uninitialized data") always initializes len to zero so that the
> name comparison is always true. As a result, "ip maddr show dev eth0" shows
> IPv4 multicast addresses for all interfaces.
> 
> Instead of keeping the length, let's simply replace the trailing colon with
> a null byte. The bonus is that we get correct interface name in ma.name.
> 
> Fixes: 530903dd9003 ("ip: fix igmp parsing when iface is long")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Acked-by: Phil Sutter <phil@nwl.cc>
