From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 03/12] ipmr: Add FIB notification access
 functions
Date: Mon, 25 Sep 2017 12:35:57 +0300
Message-ID: <4c09e09c-d184-0d69-110d-a3d5ba721564@cumulusnetworks.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:49682 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932817AbdIYJgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:36:01 -0400
Received: by mail-wm0-f41.google.com with SMTP id r74so17568304wme.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:36:01 -0700 (PDT)
In-Reply-To: <20170924172212.10096-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/17 20:22, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Make the ipmr module register as a FIB notifier. To do that, implement both
> the ipmr_seq_read and ipmr_dump ops.
> 
> The ipmr_seq_read op returns a sequence counter that is incremented on
> every notification related operation done by the ipmr. To implement that,
> add a sequence counter in the netns_ipv4 struct and increment it whenever a
> new MFC route or VIF are added or deleted. The sequence operations are
> protected by the RTNL lock.
> 
> The ipmr_dump iterates the list of MFC routes and the list of VIF entries
> and sends notifications about them. The entries dump is done under RCU
> where the VIF dump uses the mrt_lock too, as the vif->dev field can change
> under RCU.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - Take the mrt_lock when dumping VIF entries.
> ---
>  include/linux/mroute.h   |  15 ++++++
>  include/net/netns/ipv4.h |   3 ++
>  net/ipv4/ipmr.c          | 137 ++++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 153 insertions(+), 2 deletions(-)
> 

LGTM,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
