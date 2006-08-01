From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Mon, 31 Jul 2006 18:13:14 -0700 (PDT)
Message-ID: <20060731.181314.27783697.davem@davemloft.net>
References: <m3r701zgku.fsf@defiant.localdomain>
	<20060731.132324.65197403.davem@davemloft.net>
	<m3fyghz2oz.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49363
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030380AbWHABN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 21:13:58 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3fyghz2oz.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Tue, 01 Aug 2006 03:04:28 +0200

> hdlc_fr: logical PVC devices have no headers (plain IPv4 etc. as seen
> by tcpdump), but they append FR headers (4 or 10 bytes long) just
> before passing the skb to physical device.

If you hooked up fr_hard_header into dev->hard_header instead of
invoking it via pvc_xmit(), everything would be fine.

The complexity of this function arises from the fact that it prepends
headers of differing lengths depending upon the protocol type
being encapsulated, and this is the problem you should aim to
solve.

Alexey, any suggestions on how to handle this kind of thing?

