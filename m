From: David Miller <davem@davemloft.net>
Subject: Re: netlink: avoid memset of 0 bytes sparse warning
Date: Thu, 20 Nov 2008 04:09:23 -0800 (PST)
Message-ID: <20081120.040923.228828982.davem@davemloft.net>
References: <49241AFC.5030705@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755197AbYKTMJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:09:23 -0500
In-Reply-To: <49241AFC.5030705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 19 Nov 2008 14:56:12 +0100

>     netlink: avoid memset of 0 bytes sparse warning
>     
>     A netlink attribute padding of zero triggers this sparse warning:
>     
>     include/linux/netlink.h:245:8: warning: memset with byte count of 0
>     
>     Avoid the memset when the size parameter is constant and requires no padding.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-next-2.6, but I totally disagree with this sparse warning.

GCC even elides the memset entirely if it can determine the length
is constant and 0.

