From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/5] net: dsa: Multi-CPU ground work (v2)
Date: Tue, 6 Jun 2017 17:05:58 -0700
Message-ID: <970567bd-b906-5f59-5786-526027b3d32d@gmail.com>
References: <20170607000317.14729-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35318 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdFGAGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:06:04 -0400
Received: by mail-wr0-f193.google.com with SMTP id g76so11495184wrd.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:06:04 -0700 (PDT)
In-Reply-To: <20170607000317.14729-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 05:03 PM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series prepares the ground for adding mutliple CPU port support to
> DSA, and starts by removing redundant pieces of information such as
> master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from
> directly accessing ds->dst->cpu_dp and use appropriate helper functions.
> 
> Note that if you have Device Tree blobs/platform configurations that are
> currently listing multiple CPU ports, the proposed behavior in
> dsa_ds_get_cpu_dp() will be to return the last bit set in ds->cpu_port_mask.
> 
> Future plans include:
> - making dst->cpu_dp a flexible data structure (array, list, you name it)
> - having the ability for drivers to return a default/preferred CPU port (if
>   necessary)
> 
> Changes in v2:
> 
> - added Reviewed-by tags
> - assign port->cpu_dp earlier before ops->setup() has run

There are some hunks in patch 5 that actually belong in patch 3, I will
post a v3 after getting some more feedback.

> 
> Florian Fainelli (5):
>   net: dsa: Remove master_netdev and use dst->cpu_dp->netdev
>   net: dsa: Relocate master ethtool operations
>   net: dsa: Associate slave network device with CPU port
>   net: dsa: Introduce dsa_dst_get_cpu_dp()
>   net: dsa: Stop accessing ds->dst->cpu_dp in drivers
> 
>  drivers/net/dsa/b53/b53_common.c |  4 +--
>  drivers/net/dsa/bcm_sf2.c        | 10 +++++---
>  drivers/net/dsa/mt7530.c         |  6 +++--
>  drivers/net/dsa/mv88e6060.c      |  2 +-
>  drivers/net/dsa/qca8k.c          |  2 +-
>  include/net/dsa.h                | 29 +++++++++-------------
>  net/dsa/dsa.c                    | 19 ++++----------
>  net/dsa/dsa2.c                   | 27 ++++++++++++--------
>  net/dsa/dsa_priv.h               | 10 ++++++++
>  net/dsa/legacy.c                 | 23 ++++++++++-------
>  net/dsa/slave.c                  | 53 ++++++++++++++++++++--------------------
>  net/dsa/tag_brcm.c               |  5 ++--
>  net/dsa/tag_ksz.c                |  5 ++--
>  net/dsa/tag_qca.c                |  3 ++-
>  net/dsa/tag_trailer.c            |  5 ++--
>  15 files changed, 107 insertions(+), 96 deletions(-)
> 


-- 
Florian
