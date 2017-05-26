From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [for-next 5/6] net/mlx5: Bump driver version
Date: Fri, 26 May 2017 14:53:18 -0700
Message-ID: <20170526145318.7fd8c8e2@cakuba.netronome.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
        <20170523114404.20387-6-saeedm@mellanox.com>
        <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
        <CALzJLG_ha-XiPAMnoKrUgm_EwPx2yH0T2y4EBRfrWNYSZi1cTg@mail.gmail.com>
        <ee23ad82-4a2e-8546-d41b-11f979b127bb@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Dennis Dalessandro <dennis.dalessandro@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:56855 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1948760AbdEZVxf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 17:53:35 -0400
In-Reply-To: <ee23ad82-4a2e-8546-d41b-11f979b127bb@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 May 2017 12:55:22 -0400, Dennis Dalessandro wrote:
> >> I realize Dave has already pulled this and I'm not asking for it to be
> >> reverted but maybe some discussion will help guide future patch submissions
> >> which do this stuff.
> >>  
> > 
> > Sure, although i don't think we are going to use those version fields
> > in the future,
> > please allow me to ask, how do you do your driver versioning ? how do
> > you track things ?
> > and what is your future vision regarding ethool->drv_version ?  
> 
> That's just the thing, we don't do anything with it either really. I'm 
> trying to justify its existence to myself and if you folks had some whiz 
> bang idea for a driver version I was interested in hearing what it was.

FWIW I put VERMAGIC_STRING in drv_version:

# ethtool -i p4p1
driver: nfp
version: 4.12.0-rc2-perf-00282-gc42dfc79
...

I think I got that idea from Felix Fietkau.  The backport-ified version
of the driver [1] uses git hash and "o-o-t" sting:

# ethtool -i p4p1
driver: nfp
version: 49e5c6abf5b2 (o-o-t)
...

So it's pretty easy to tell which driver the customer is using.  I
could probably throw in the output of $(git rev-list --count HEAD) to
have an automatic monotonically increasing "version" when built
out-of-tree, hm...

[1] https://github.com/Netronome/nfp-drv-kmods
