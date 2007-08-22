From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AH4: Update IPv4 options handling to conform to RFC
 4302.
Date: Wed, 22 Aug 2007 12:34:44 -0700 (PDT)
Message-ID: <20070822.123444.108812154.davem@davemloft.net>
References: <20070822142253.GA14870@totient.ellipticsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nbowler@ellipticsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751989AbXHVTes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 15:34:48 -0400
In-Reply-To: <20070822142253.GA14870@totient.ellipticsemi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Bowler <nbowler@ellipticsemi.com>
Date: Wed, 22 Aug 2007 10:22:53 -0400

> In testing our ESP/AH offload hardware, I discovered an issue with how AH
> handles mutable fields in IPv4.  RFC 4302 (AH) states the following on the
> subject:
> 
>         For IPv4, the entire option is viewed as a unit; so even
>         though the type and length fields within most options are immutable
>         in transit, if an option is classified as mutable, the entire option
>         is zeroed for ICV computation purposes.
> 
> The current implementation does not zero the type and length fields, resulting
> in authentication failures when communicating with hosts that do (i.e. FreeBSD).
> 
> I have tested record route and timestamp options (ping -R and ping -T) on a
> small network involving Windows XP, FreeBSD 6.2, and Linux hosts, with one
> router.  In the presence of these options, the FreeBSD and Linux hosts (with
> the patch or with the hardware) can communicate.  The Windows XP host simply
> fails to accept these packets with or without the patch.
> 
> I have also been trying to test source routing options (using traceroute -g),
> but haven't had much luck getting this option to work *without* AH, let alone
> with.
> 
> Signed-off-by: Nick Bowler <nbowler@ellipticsemi.com>

Patch applied, thanks a lot Nick.
