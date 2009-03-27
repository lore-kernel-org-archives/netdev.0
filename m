From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_rose/x25: Sanity check the maximum user frame size
Date: Fri, 27 Mar 2009 00:29:20 -0700 (PDT)
Message-ID: <20090327.002920.134973741.davem@davemloft.net>
References: <20090326215826.18836.86957.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbZC0H3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:29:32 -0400
In-Reply-To: <20090326215826.18836.86957.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 26 Mar 2009 21:58:51 +0000

> Otherwise we can wrap the sizes and end up sending garbage.
> 
> Closes #10423
> 
> Signed-off-by: Alan Cox <alan@lxorguk.ukuu.org.uk>

Applied, but:

> -	/* Build a packet */
> +	/* Build a packet - the conventional user limit is 236 bytes. We can
> +	   do ludicrously large NetROM frames but must not overflow */
> +	if (len > 65536)
> +		return -EMSGSIZE;
> +	
   ^^^^^^^^^^^^^

please fix the tab monster :-) Or, alternatively, check the patch
either with GIT's automatic checks (or using checkpatch.pl if you
haven't eaten recently)

