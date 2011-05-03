From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/5] bnx2x: link report improvements
Date: Tue, 03 May 2011 16:05:08 -0700 (PDT)
Message-ID: <20110503.160508.226773770.davem@davemloft.net>
References: <1304429925.19456.11.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753505Ab1ECXFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 19:05:41 -0400
In-Reply-To: <1304429925.19456.11.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 3 May 2011 16:38:45 +0300

> From: Vladislav Zolotarov <vladz@broadcom.com>
> 
> To avoid link notification duplications
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

You go through all of the effort to use atomic bit operations
on the link state statue flags, then do a memcpy() to propagate
new state into the software state structure which is not atomic.

Either it needs to be atomic or it does not.

If it doesn't use __set_bit() and friends and document exactly
what synchronizes and protects access to this object.
