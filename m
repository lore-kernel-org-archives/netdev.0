From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] gianfar: Implement workaround for eTSEC76
 erratum
Date: Wed, 30 Jun 2010 11:37:19 -0700 (PDT)
Message-ID: <20100630.113719.128591285.davem@davemloft.net>
References: <20100630163804.GA636@oksana.dev.rtsoft.ru>
	<20100630163913.GB23337@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756962Ab0F3ShG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 14:37:06 -0400
In-Reply-To: <20100630163913.GB23337@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Wed, 30 Jun 2010 20:39:13 +0400

> MPC8313ECE says:
> 
> "For TOE=1 huge or jumbo frames, the data required to generate the
>  checksum may exceed the 2500-byte threshold beyond which the controller
>  constrains itself to one memory fetch every 256 eTSEC system clocks.
> 
>  This throttling threshold is supposed to trigger only when the
>  controller has sufficient data to keep transmit active for the duration
>  of the memory fetches. The state machine handling this threshold,
>  however, fails to take large TOE frames into account. As a result,
>  TOE=1 frames larger than 2500 bytes often see excess delays before start
>  of transmission."
> 
> This patch implements the workaround as suggested by the errata
> document, i.e.:
> 
> "Limit TOE=1 frames to less than 2500 bytes to avoid excess delays due to
>  memory throttling.
>  When using packets larger than 2700 bytes, it is recommended to turn TOE
>  off."
> 
> To be sure, we limit the TOE frames to 2500 bytes, and do software
> checksumming instead.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Applied.
