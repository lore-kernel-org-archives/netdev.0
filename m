From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 01/18] bridge: Export VLAN filtering state
Date: Fri, 26 May 2017 17:02:00 +0300
Message-ID: <20170526140200.GA1037@splinter>
References: <20170526063740.8909-1-jiri@resnulli.us>
 <20170526063740.8909-2-jiri@resnulli.us>
 <b2edc91e-d7cf-a667-2b00-5722ed09a2a6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <mlxsw@mellanox.com>,
        <stephen@networkplumber.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20042.outbound.protection.outlook.com ([40.107.2.42]:43952
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1947850AbdEZOCI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 10:02:08 -0400
Content-Disposition: inline
In-Reply-To: <b2edc91e-d7cf-a667-2b00-5722ed09a2a6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nik,

On Fri, May 26, 2017 at 11:55:18AM +0300, Nikolay Aleksandrov wrote:
> On 5/26/17 9:37 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > It's useful for drivers supporting bridge offload to be able to query
> > the bridge's VLAN filtering state.
> > 
> > Currently, upon enslavement to a bridge master, the offloading driver
> > will only learn about the bridge's VLAN filtering state after the bridge
> > device was already linked with its slave.
> > 
> > Being able to query the bridge's VLAN filtering state allows such
> > drivers to forbid enslavement in case resource couldn't be allocated for
> > a VLAN-aware bridge and also choose the correct initialization routine
> > for the enslaved port, which is dependent on the bridge type.
> > 
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >   include/linux/if_bridge.h | 9 +++++++++
> >   net/bridge/br_if.c        | 2 +-
> >   net/bridge/br_mdb.c       | 4 ++--
> >   net/bridge/br_netlink.c   | 2 +-
> >   net/bridge/br_private.h   | 9 ---------
> >   net/bridge/br_vlan.c      | 8 ++++++++
> >   6 files changed, 21 insertions(+), 13 deletions(-)
> > 
> 
> I must say this bridge -> dev -> bridge looks weird from the bridge POV.
> Since exports like this seem to be increasing I think it'd be nice to
> make some API that can be queried instead of exporting symbols for each
> bridge option or attribute. In this case maybe a simpler solution would've
> been only a new exported symbol for external users.

It seemed more logical to me to export the existing function, but I can
instead leave it as-is and introduce a new symbol. I'll wait for more
comments and send a v2 if deemed necessary.

> The patch itself looks good to me.
> 
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks for reviewing!
