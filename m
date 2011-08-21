From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] net: add APIs for manipulating skb page fragments.
Date: Sun, 21 Aug 2011 09:23:57 +0100
Message-ID: <1313915037.17978.686.camel@dagon.hellion.org.uk>
References: <1313771100-22993-1-git-send-email-ian.campbell@citrix.com>
	 <20110820.173133.1612902138924735868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:43370 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab1HUIYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 04:24:22 -0400
In-Reply-To: <20110820.173133.1612902138924735868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-21 at 01:31 +0100, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Fri, 19 Aug 2011 17:25:00 +0100
> 
> > The primary aim is to add skb_frag_(ref|unref) in order to remove the use of
> > bare get/put_page on SKB pages fragments and to isolate users from subsequent
> > changes to the skb_frag_t data structure.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> 
> You're going to have to protect all of the things using the interfaces
> from linux/dma-mapping.h with CONFIG_HAS_DMA otherwise it won't build
> on platforms like S390.

s390 is one of the arches which I build tested and I initially saw this
issue too. I did add CONFIG_HAS_DMA but it turns out that
linux/dma-mapping.h takes care of this by including
asm-generic/dma-mapping-broken.h for you so I removed the #ifdef again.
The header defines the prototypes to allow building but causes a link
time failure if anything actually uses the interfaces.

I just tested a s390x defconfig build again and it appears to be fine.

Ian.

