From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0
 directly if relay_prefixlen == 0.
Date: Mon, 12 Oct 2009 01:18:02 -0700 (PDT)
Message-ID: <20091012.011802.119775755.davem@davemloft.net>
References: <4AD1E169.6090705@linux-ipv6.org>
	<4AD2DB99.3070208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754659AbZJLISH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 04:18:07 -0400
In-Reply-To: <4AD2DB99.3070208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 12 Oct 2009 09:32:41 +0200

> Sorry I dont get it
> 
> u32 val = any_value ;
> u32 relay_prefix = val & htonl(0xffffffffUL << 32) should give 0
> 
> If not, something is broken and should be fixed.

Indeed, it's "x >> 32" which is undefined and has to be done as
something like "(x >> 31) >> 1" when performed on a u32 object.

Yoshfuji is this patch really necessary?
