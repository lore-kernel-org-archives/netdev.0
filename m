From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 06/16] sfc: Introduce and use
 MCDI_DECLARE_BUF macro
Date: Thu, 22 Aug 2013 22:02:36 -0700 (PDT)
Message-ID: <20130822.220236.2202751653391527307.davem@davemloft.net>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
	<1377199609.1703.55.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653Ab3HWFCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 01:02:41 -0400
In-Reply-To: <1377199609.1703.55.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 22 Aug 2013 20:26:49 +0100

> MCDI_DECLARE_BUF declares a variable as an MCDI buffer of the
> requested length, adding any necessary padding.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

There really isn't a guarentee that a u8 array is going to
aligned appropriately to write dwords there using casts like
you do.

Since you're here macro'izing the declaration, take the time to fix it
to specify the necessary alignment as well.

You probably are getting lucky and this works because the size of
all the stack items allocated by gcc for these functions all are
sized such that nothing ends up being unaligned.  But code should not
work by luck :-)

Thanks.
