From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 07:28:28 -0800
Message-ID: <1353425308.2590.11.camel@edumazet-glaptop>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
	 <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
	 <1353418516.13542.38.camel@zakaz.uk.xensource.com>
	 <50AB990602000078000A9F5B@nat28.tlf.novell.com>
	 <1353420865.13542.44.camel@zakaz.uk.xensource.com>
	 <50ABA29902000078000A9FB1@nat28.tlf.novell.com>
	 <1353424014.13542.49.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Beulich <JBeulich@suse.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Eric Dumazet <edumazet@google.com>,
	KonradRzeszutekWilk <konrad@kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	ANNIE LI <annie.li@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:63489 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2KTP2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 10:28:33 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so8722007iea.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 07:28:33 -0800 (PST)
In-Reply-To: <1353424014.13542.49.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 15:06 +0000, Ian Campbell wrote:

> In practice no because of the property that the number of pages backing
> the frags is <= MAX_SKB_FRAGS even if you are using compound pages as
> the frags.

Yes, but you can make this test trigger with some hacks from userland
(since the frag allocator is per task instead of per socket), so you
should remove the dump_stack() ?

Best way would be to count exact number of slots.

This could be something like 48 slots for a single skb

(if each frag is 4098 (1+4096+1)bytes, only the last one is around 4000
bytes)

MAX_SKB_FRAGS is really number of frags, while your driver needs a count
of 'order-0' 'frames'
