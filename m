From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3 1/2] vxlan: introduce vxlan_rdst_append
Date: Wed, 29 May 2013 15:56:42 -0700
Message-ID: <20130529155642.391b50b3@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-2-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:34187 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966998Ab3E2W4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 18:56:46 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so9973728pbc.14
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 15:56:46 -0700 (PDT)
In-Reply-To: <1369821617-29098-2-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 13:00:15 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> -/* Add/update destinations for multicast */
> -static int vxlan_fdb_append(struct vxlan_fdb *f,
> -			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
> +static int vxlan_rdst_append(struct vxlan_rdst *rdst, __be32 ip, __be16 port,
> +			     __u32 vni, __u32 ifindex)
>  {
>  	struct vxlan_rdst *rd_prev, *rd;
>  
>  	rd_prev = NULL;
> -	for (rd = &f->remote; rd; rd = rd->remote_next) {
> +	for (rd = rdst; rd; rd = rd->remote_next) {

The remote destinations should be using one of our nice list macros.
And what about locking? or RCU?
