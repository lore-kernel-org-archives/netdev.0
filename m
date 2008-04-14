From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [IPV6] MIP6: Ensure independence from
 alignment.
Date: Sun, 13 Apr 2008 22:26:29 -0700 (PDT)
Message-ID: <20080413.222629.180789339.davem@davemloft.net>
References: <20080409.004632.68333196.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751698AbYDNF01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:26:27 -0400
In-Reply-To: <20080409.004632.68333196.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 09 Apr 2008 00:46:32 +0900 (JST)

> We cannot rely on sizeof(struct ipv6_opt_hdr) when we are handling
> wire format, because it may not be 2 but 4 on some architectures.
> On such a architecture, the result can be different from what we
> actually expect.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Please just mark the structure with "packed" attribute.

It is appropriate in this case, and there should be no cost
because members are 8-byte quantities.

Otherwise, mistakes are likely to be added in the future.
It is very reasonable to expect the structure size for
a networking header to match correctly.
 
