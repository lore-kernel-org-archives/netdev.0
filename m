From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 6/6] net/faraday: Enable offload checksum according
 to device-tree
Date: Mon, 9 Nov 2015 11:45:01 +1100
Message-ID: <20151109004501.GA17877@gwshan>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447027806-4744-7-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447029370.8727.33.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:34608 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbKIAqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:46:07 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:46:05 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 42A3B2CE8055
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:46:01 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90jqLH43122692
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:46:01 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90jSXF002926
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:45:28 +1100
Content-Disposition: inline
In-Reply-To: <1447029370.8727.33.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 11:36:10AM +1100, Benjamin Herrenschmidt wrote:
>On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
>> This enables IP/UDP/TCP offload checksum according to information
>> passed on from bootloader through device-tree. The offload doesn't
>> working properly when the interface works in NCSI mode.
>>=20
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>> ---
>> =A0drivers/net/ethernet/faraday/ftgmac100.c | 5 ++++-
>> =A01 file changed, 4 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/=
ethernet/faraday/ftgmac100.c
>> index 1b13fd4..1e2f4d2 100644
>> --- a/drivers/net/ethernet/faraday/ftgmac100.c
>> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
>> @@ -1377,7 +1377,10 @@ static int ftgmac100_probe(struct platform_de=
vice *pdev)
>> =A0
>> =A0> 	> netdev->ethtool_ops =3D &ftgmac100_ethtool_ops;
>> =A0> 	> netdev->netdev_ops =3D &ftgmac100_netdev_ops;
>> -> 	> netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_GRO;
>> +> 	> netdev->features =3D NETIF_F_GRO;
>> +> 	> if (pdev->dev.of_node &&
>> +> 	> =A0=A0=A0=A0of_property_read_bool(pdev->dev.of_node, "no-hw-ch=
ecksum"))
>> +> 	> 	> netdev->features |=3D NETIF_F_IP_CSUM;
>
>Am I reading properly that if you put "no-hw-checksum" in the device-
>tree you *enable* HW checksum ? This doesn't look right to me...
>
>The logic should be:
>
>	if (pdev->dev.of_node &&
>		of_property_read_bool(pdev->dev.of_node, "no-hw-checksum"))
>		netdev->features &=3D ~NETIF_F_IP_CSUM;
>

Thanks, Ben. You're right. This flag affects TCP flows and I didn't tes=
t
it with this series of patchset. I'll adjust the code accordingly in ne=
xt
respin.

Thanks,
Gavin
