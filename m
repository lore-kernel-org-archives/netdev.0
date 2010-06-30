From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] [PATCH] ethtool: Change ethtool_op_set_flags to validate
 flags
Date: Wed, 30 Jun 2010 01:26:54 -0400
Message-ID: <4C2AD59E.10008@garzik.org>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com> <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org> <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com> <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org> <20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com> <1277734724.2089.10.camel@achroite.uk.solarflarecom.com> <1277822484.2112.19.camel@achroite.uk.solarflarecom.com> <20100629170025.7a130e28@dhcp-lab-109.englab.brq.redhat.com> <1277823923.2112.26.camel@achroite.uk.solarflarecom.com> <1277827261.2112.48.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:56813 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab0F3F07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 01:26:59 -0400
Received: by gwb15 with SMTP id 15so194745gwb.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 22:26:58 -0700 (PDT)
In-Reply-To: <1277827261.2112.48.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 12:01 PM, Ben Hutchings wrote:
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
>   drivers/net/cxgb4/cxgb4_main.c    |    9 +--------
>   drivers/net/enic/enic_main.c      |    1 -
>   drivers/net/ixgbe/ixgbe_ethtool.c |    5 ++++-
>   drivers/net/mv643xx_eth.c         |    7 ++++++-
>   drivers/net/myri10ge/myri10ge.c   |   10 +++++++---
>   drivers/net/niu.c                 |    9 +--------
>   drivers/net/sfc/ethtool.c         |    5 +----
>   drivers/net/sky2.c                |   16 ++++++----------
>   include/linux/ethtool.h           |    2 +-
>   net/core/ethtool.c                |   28 +++++-----------------------
>   10 files changed, 32 insertions(+), 60 deletions(-)

Acked-by: Jeff Garzik <jgarzik@redhat.com>

I think that's a better way to do it...


