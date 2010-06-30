From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC] [PATCH] ethtool: Change ethtool_op_set_flags to validate
 flags
Date: Wed, 30 Jun 2010 13:21:11 +0200
Message-ID: <20100630132111.72559f9f@dhcp-lab-109.englab.brq.redhat.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
	<20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
	<20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com>
	<1277734724.2089.10.camel@achroite.uk.solarflarecom.com>
	<1277822484.2112.19.camel@achroite.uk.solarflarecom.com>
	<20100629170025.7a130e28@dhcp-lab-109.englab.brq.redhat.com>
	<1277823923.2112.26.camel@achroite.uk.solarflarecom.com>
	<1277827261.2112.48.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab0F3LVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 07:21:24 -0400
In-Reply-To: <1277827261.2112.48.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jun 2010 17:01:01 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> This is the sort of change I'd like to see.
> 
> Ben.
> 
> ---
> ethtool_op_set_flags() does not check for unsupported flags, and has
> no way of doing so.  This means it is not suitable for use as a
> default implementation of ethtool_ops::set_flags.
> 
> Add a 'supported' parameter specifying the flags that the driver and
> hardware support, validate the requested flags against this, and
> change all current callers to pass this parameter.
> 
> Change some other trivial implementations of ethtool_ops::set_flags to
> call ethtool_op_set_flags().
> ---
>  drivers/net/cxgb4/cxgb4_main.c    |    9 +--------
>  drivers/net/enic/enic_main.c      |    1 -
>  drivers/net/ixgbe/ixgbe_ethtool.c |    5 ++++-
>  drivers/net/mv643xx_eth.c         |    7 ++++++-
>  drivers/net/myri10ge/myri10ge.c   |   10 +++++++---
>  drivers/net/niu.c                 |    9 +--------
>  drivers/net/sfc/ethtool.c         |    5 +----
>  drivers/net/sky2.c                |   16 ++++++----------
>  include/linux/ethtool.h           |    2 +-
>  net/core/ethtool.c                |   28 +++++-----------------------
>  10 files changed, 32 insertions(+), 60 deletions(-)

Looks good for me as well.

Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
