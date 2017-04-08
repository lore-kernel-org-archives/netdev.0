From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing ndo_uninit()
Date: Sat, 8 Apr 2017 10:14:01 -0400
Message-ID: <20170408101401.10ee916e@plumbers-lap.home.lan>
References: <20170408114159.12722-1-idosch@mellanox.com>
        <20170408114159.12722-2-idosch@mellanox.com>
        <20170408093042.20b08c5d@plumbers-lap.home.lan>
        <20170408134938.GA28955@splinter>
        <59220a2b-aa54-844d-cda5-63a42b88f188@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@idosch.org>, idosch@mellanox.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, peter@svinota.eu, cera@cera.cz,
        mlxsw@mellanox.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33758 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdDHOOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 10:14:05 -0400
Received: by mail-io0-f170.google.com with SMTP id t68so29960652iof.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 07:14:05 -0700 (PDT)
In-Reply-To: <59220a2b-aa54-844d-cda5-63a42b88f188@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Apr 2017 17:05:48 +0300
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> On 08/04/17 16:49, Ido Schimmel wrote:
> > On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote:  
> >> On Sat, 8 Apr 2017 14:41:58 +0300
> >> <idosch@mellanox.com> wrote:
> >>  
> >>>  static void br_dev_free(struct net_device *dev)
> >>>  {
> >>> -	struct net_bridge *br = netdev_priv(dev);
> >>> -
> >>> -	free_percpu(br->stats);
> >>>  	free_netdev(dev);
> >>>  }
> >>>    
> >>
> >> Since the only thing left is free_netdev, you can now just set dev->destructor
> >> to be free_netdev.  
> > 
> > Fine.
> > 
> > Beside stylistic issues, I would appreciate comments on how this should
> > be handled. Are we reverting the patch in the Fixes line or applying
> > this patchset?
> > 
> > I prefer the first option. Then after net is merged into net-next I can
> > re-post this patchset with the requested changes.
> >   
> 
> +1
> 
> 

If this fixes the issue, then the one fix should go to stable, net and net-next.
There is no good reason to have two versions.
