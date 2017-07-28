From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC] switchdev: generate phys_port_name in the core
Date: Fri, 28 Jul 2017 00:28:57 -0700
Message-ID: <20170728002857.164d128d@cakuba.netronome.com>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
        <20170728023122.1674-1-jakub.kicinski@netronome.com>
        <20170728053507.GA1857@nanopsycho>
        <20170728055815.GB1857@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35844 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdG1H3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 03:29:04 -0400
Received: by mail-pg0-f51.google.com with SMTP id 125so107935068pgi.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 00:29:03 -0700 (PDT)
In-Reply-To: <20170728055815.GB1857@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jul 2017 07:58:15 +0200, Jiri Pirko wrote:
> Fri, Jul 28, 2017 at 07:35:07AM CEST, jiri@resnulli.us wrote:
> >Fri, Jul 28, 2017 at 04:31:22AM CEST, jakub.kicinski@netronome.com wrote:  
> >>On Thu, 27 Jul 2017 13:30:44 +0300, Or Gerlitz wrote:  
> >>> > want to add port splitting support, for example, reporting the name on
> >>> > physical ports will become more of a necessity.    
> >>>   
> >>> > If we adopt Jiri's suggestion of returning structured data it will be
> >>> > very easy to give user space type and indexes separately, but we should
> >>> > probably still return the string for backwards compatibility.    
> >>> 
> >>> I am not still clear how the structured data would look like  
> >>
> >>I decided to just quickly write the code, that should be easier to 
> >>understand.  We can probably leave out the netlink part of the API
> >>if there is no need for it right now, but that's what I ment by
> >>returning the information in a more structured way.
> >>
> >>Tested-by: nobody :)
> >>Suggested-by: Jiri (if I understood correctly)  
> >
> >Yes, you did :) Couple of nits inlined.
> >
> >  
> >>---
> >> drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |  8 ++-
> >> drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 10 ++--
> >> drivers/net/ethernet/netronome/nfp/nfp_port.c    | 26 ++++-----
> >> drivers/net/ethernet/netronome/nfp/nfp_port.h    |  4 +-
> >> include/linux/netdevice.h                        | 18 ++++++-
> >> include/uapi/linux/if_link.h                     | 16 ++++++
> >> net/core/dev.c                                   | 31 +++++++++--
> >> net/core/rtnetlink.c                             | 69 ++++++++++++++++++++++++
> >> 8 files changed, 153 insertions(+), 29 deletions(-)
> >>
> >>diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> >>index 45e60be9c277..7a71291b8ec3 100644
> >>--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> >>+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
> >>@@ -637,16 +637,14 @@ static int mlx5e_rep_close(struct net_device *dev)
> >> }
> >> 
> >> static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
> >>-					char *buf, size_t len)
> >>+					struct netdev_port_info *info)  
> >
> >Either we rename ndo to something like ndo_get_port_info or you rename
> >the struct to netdev_port_name_info. These 2 should be in sync  
> 
> As this is strictly related to port name, I think it should be:
> struct netdev_phys_port_name_info
> 
> And the rest named in-sync with this

Hm..  Since we would return the type and IDs via netlink, I was
actually leaning towards ndo_get_port_info.  "Name" somehow implies a
string in my mind.  Perhaps the "info" part is where I went wrong, could
we go with netdev_port_label?  Or netdev_port_ident?  I would also
prefer to avoid the phys in name, since it doesn't sit well with PFs
vs VFs.

Ah, naming things...
