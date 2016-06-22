From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text
 ~10k/5%
Date: Wed, 22 Jun 2016 14:40:56 -0600
Message-ID: <20160622204056.GB20838@obsidianresearch.com>
References: <1466619839.13093.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60297 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750904AbcFVUlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 16:41:01 -0400
Content-Disposition: inline
In-Reply-To: <1466619839.13093.4.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 11:23:59AM -0700, Joe Perches wrote:

> The output changes now do not include line #, but do include the
> function offset.

I've been using a technique like this in some code with good results:

struct source_location
{
   const char *file;
   const char *func;
   const char *format;
   uint16_t line;
};
#define _LOCATION(format) ({static const source_location __location__ = {\
             __FILE__,__PRETTY_FUNCTION__,format,__LINE__};\
	     &__location__;})

void _mlx5_core_err(const struct source_location *loc,struct mlx5_core_dev *dev, ...);
#define mlx5_core_err(dev,format,...) _mlx_core_err(_LOCATION(format),dev,__VA_ARGS__)

The call site .text overhead is the about same as what you have, but
this still retains the function and line number information in
.rodata.

Jason
