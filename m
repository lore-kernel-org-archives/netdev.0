From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: compound skb frag pages appearing in start_xmit
Date: Tue, 9 Oct 2012 14:47:47 +0100
Message-ID: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:30565 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659Ab2JINru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 09:47:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Sander has discovered an issue where xen-netback is given a compound
page as one of the skb frag pages to transmit. Currently netback can
only handle PAGE_SIZE'd frags and bugs out.

I suspect this is something to do with 69b08f62e174 "net: use bigger
pages in __netdev_alloc_frag", although perhaps not because it looks
like only tg3 uses it and Sander has an r8169. Also tg3 seems to only
call netdev_alloc_frag for sizes < PAGE_SIZE. I'm probably missing
something.

Are all net drivers expected to be able to handle compound pages in the
frags? Obviously it is to their benefit to do so, so it is something
I'll want to look into for netback.

I expect the main factor here is bridging/forwarding, since the
receiving NIC and its driver appear to support compound pages but the
outgoing NIC (netback in this case) does not.

I guess my question is should I be rushing to fix netback ASAP or should
I rather be looking for a bug somewhere which caused a frag of this type
to get as far as netback's start_xmit in the first place?

Or am I just barking up the wrong tree to start with?

Thanks,
Ian.
