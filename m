From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [Qemu-devel] [PATCH] net: add raw backend  - some performance
 measurements
Date: Tue, 21 Jul 2009 14:05:32 +0300
Message-ID: <4A65A0FC.6090204@Voltaire.com>
References: <4A4CA747.1050509@Voltaire.com>	<20090703023911.GD938@shareable.org> <4A534EC4.5030209@voltaire.com>	<20090707145739.GB14392@shareable.org> <4A54B0F1.3070201@voltaire.com>	<20090715203806.GF3056@shareable.org> <4A647B72.5090404@Voltaire.com>	<20090720155308.GA9327@gondor.apana.org.au> <4A656824.7070100@Voltaire.com>	<20090721072546.GA16131@gondor.apana.org.au> <20090721102733.GB22155@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jamie Lokier <jamie@shareable.org>,
	Anthony Liguori <anthony@codemonkey.ws>, qemu-devel@nongnu.org,
	Jan Kiszka <jan.kiszka@web.de>,
	Mark McLoughlin <markmc@redhat.com>,
	Dor Laor <dlaor@redhat.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:16347 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752802AbZGULFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 07:05:43 -0400
In-Reply-To: <20090721102733.GB22155@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:
> With raw sockets, send will block or fail if the TX queue for device is
> full. With tap+bridge, the buffer in tap has to fill up instead, which
> is not the same. I'm not sure this is the issue here, but could be: the
> benchmark is UDP, isn't it?

Michael, 

What/where is this tap buffer? we're talking on VM TX, so looking on tun_get_user I see a call to 
skb_copy_datagram_from_iovec() to copy from the user buffer to an skb, then a call to netif_rx_ni() and that's it... As for your question, indeed udp, the VM runs netperf/UDP_STREAM

Or.

