From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Ethernet Frame Generation
Date: Tue, 27 Mar 2007 19:47:49 +0400
Message-ID: <20070327154749.GA31957@2ka.mipt.ru>
References: <20070327.224537.09436398.yoshfuji@linux-ipv6.org> <20070327142519.GN521@postel.suug.ch> <460937EE.8050703@lionking.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Simba <simba@lionking.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58211 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282AbXC0Pr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 11:47:59 -0400
Content-Disposition: inline
In-Reply-To: <460937EE.8050703@lionking.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 05:27:42PM +0200, Simba (simba@lionking.at) wrote:
> I am currently working on a new l2/l3 protocol (just for
> research reasons) and i would like to make a test implementation
> in the linux kernel.
> 
> For this i need to modify the ethernet header and replace it
> with my header. The payload of this header holds the raw data, or
> an TCP segment, or an UDP datagram.

How will your hardware handle that new protocol?

Anyway, you need to setup skb and call driver's ->hard_start_xmit() 
callback under tx lock with check if driver allows to transmit data.

Check net/pktgen.c -> pktgen_xmit() function.

The simplest way to receive a packet is about putting your code into 
netif_receive_skb().

-- 
	Evgeniy Polyakov
