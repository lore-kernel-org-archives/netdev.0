From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC v1 7/7] net/faraday: Enable offload checksum
 according to device-tree
Date: Wed, 7 Oct 2015 10:19:25 +1100
Message-ID: <20151006231925.GA15742@gwshan>
References: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1444100989-3437-8-git-send-email-gwshan@linux.vnet.ibm.com>
 <5613D85E.30608@cogentembedded.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	benh@kernel.crashing.org, davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:53865 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbbJFXU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 19:20:28 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Wed, 7 Oct 2015 09:20:25 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 3C20A2CE8055
	for <netdev@vger.kernel.org>; Wed,  7 Oct 2015 10:20:23 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t96NKGIp57475318
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 10:20:24 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t96NJo8f013585
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2015 10:19:50 +1100
Content-Disposition: inline
In-Reply-To: <5613D85E.30608@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 05:19:10PM +0300, Sergei Shtylyov wrote:
>Hello.
>
>On 10/6/2015 6:09 AM, Gavin Shan wrote:
>
>>This enables IP/UDP/TCP offload checksum according to information
>>passed on from bootloader through device-tree. The offload doesn't
>>working properly when the interface works in NCSI mode.
>>
>>Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>>---
>>  drivers/net/ethernet/faraday/ftgmac100.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>>diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
>>index 1b13fd4..8caed35 100644
>>--- a/drivers/net/ethernet/faraday/ftgmac100.c
>>+++ b/drivers/net/ethernet/faraday/ftgmac100.c
>>@@ -1377,7 +1377,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
>>
>>  	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
>>  	netdev->netdev_ops = &ftgmac100_netdev_ops;
>>-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
>>+	if (pdev->dev.of_node &&
>>+	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
>
>   Why not of_property_read_bool()?
>

of_property_read_bool() is more appropriate here though both functions
are wrappers of of_find_property().

>>+		netdev->features = NETIF_F_GRO;
>>+	else
>>+		netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
>
>   Why not set NETIF_F_GRO outside of *if*?
>

Ok.

Thanks,
Gavin
