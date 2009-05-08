From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and TX
Date: Fri, 08 May 2009 14:44:12 -0700 (PDT)
Message-ID: <20090508.144412.201441401.davem@davemloft.net>
References: <m31vqzwzae.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbZEHVoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 17:44:16 -0400
In-Reply-To: <m31vqzwzae.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Fri, 08 May 2009 14:32:25 +0200

> Could NAPI or something similar be used for TX in addition to RX?
> Perhaps some driver already does that?

Many multiqueue drivers do exactly this.  NIU is but one example.

Every discrete event from the chip which can generate discrete
interrupts, uses a unique NAPI context.

If a single interrupt is used to indicate RX and TX, using seperate
NAPI contexts is not advisable.  It's just going to add overhead.
