From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2 v2] PS3: changed the way to handle tx skbs
Date: Fri, 31 Aug 2007 09:59:57 -0400
Message-ID: <46D81EDD.5090807@garzik.org>
References: <20070831220507.C31D.MOKUNO@sm.sony.co.jp> <20070831221800.C323.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965255AbXHaOAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 10:00:01 -0400
In-Reply-To: <20070831221800.C323.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masakazu Mokuno wrote:
> The PS3 virtual network device requires a vlan tag in the sending packet
> to select the destination device, ethernet port or wireless. 
> As the vlan tag field is in the middle of the passed data, 
> we should insert it into the packet data.
> To avoid copying much of the packet data, the driver used two tx descriptors
> for one tx skb; one descriptor was for sending a small static 
> buffer which contained vlan tag and copied header (two mac addresses),
> one was for the residual data after the vlan field.
> 
> This patch changes the way to insert the vlan tag.  By changing 
> netdev->hard_header_len, we can make the headroom for moving mac address
> fields in the skb buffer. Then we can send one tx skb with
> one tx descriptor.  This also gives us a tx throughut gain of approx.
> 20% according to netperf results.
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> CC: Geoff Levand <geoffrey.levand@am.sony.com>
> ---
>  drivers/net/ps3_gelic_net.c |  140 +++++++++++++++++++-------------------------
>  1 file changed, 63 insertions(+), 77 deletions(-)

applied 1-2, thanks for the update


