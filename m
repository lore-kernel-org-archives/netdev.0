From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 00:57:12 +0200
Message-ID: <469E9AC8.3090603@trash.net>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50228 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933580AbXGRW5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:57:51 -0400
In-Reply-To: <878246.51044.qm@web56608.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

andrei radulescu-banu wrote:
> [...]
> 
> In conclusion, here is the buglist:  
> 1). If set promiscuous, the e1000 should disable any vlan rx filtering, so that it can receive vlan frames of other vlan id's. Other ethernet drivers probably need fixed as well.
>   2). The packet layer should change the rx skb device from the vlan 'fake' device (eth0.2) to the corresponding physical device (eth0), so when we run tcpdump on eth0 we see all vlan-tagged and non-vlan-tagged frames
>   3). The packet socket layer should insert the vlan tag header before passing frames to the upper layer, so tcpdump can display them.


Put another way, once you enable VLAN header stripping, you
won't see the headers for *any* VLAN, not only for those you're
actually running locally. This is also a problem for devices
like macvlan, where it would be desirable to make use of
hardware VLAN accerlation. I was thinking about storing the
information somewhere in the packets meta-data on both RX and
TX paths, that would also allow tcpdump to properly display
packets.

I have planned to look into this when I find some time.
Your suggestion of disabling VLAN acceleration in promiscous
mode sounds like a reasonable solution until then ..

