From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] niu: Fix kernel buffer overflow for
 ETHTOOL_GRXCLSRLALL
Date: Wed, 08 Sep 2010 14:03:59 -0700 (PDT)
Message-ID: <20100908.140359.15225710.davem@davemloft.net>
References: <1283870119.2270.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santwona.behera@sun.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753392Ab0IHVDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:03:41 -0400
In-Reply-To: <1283870119.2270.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 07 Sep 2010 15:35:19 +0100

> niu_get_ethtool_tcam_all() assumes that its output buffer is the right
> size, and warns before returning if it is not.  However, the output
> buffer size is under user control and ETHTOOL_GRXCLSRLALL is an
> unprivileged ethtool command.  Therefore this is at least a local
> denial-of-service vulnerability.
> 
> Change it to check before writing each entry and to return an error if
> the buffer is already full.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Good catch, thanks Ben.

> There may be more of these but AFAIK this is the only RXNFC command that
> deals with variable-length data.
> 
> I wonder whether it really makes sense for ethtool getter commands to be
> generally unprivileged.  Does the convenience outweigh the risk of a
> driver bug becoming a local DoS or root hole, or the disclosure of
> information such as (in this case) which flows the administrator
> considers interesting?

I'm ambivalent about this specific case, to be honest.  Although one
argument for what we do now is that often admins do things as root
as little as possible and this helps that.
