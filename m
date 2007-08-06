From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PATCH] drivers/net/ibmveth.c: memset fix
Date: Mon, 6 Aug 2007 23:44:03 +0200
Message-ID: <200708062344.03443.m.kozlowski@tuxland.pl>
References: <200708062217.04361.m.kozlowski@tuxland.pl> <46B78672.9090808@linux.vnet.ibm.com> <46B78814.50508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, santil@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933007AbXHFVoZ@vger.kernel.org>
In-Reply-To: <46B78814.50508@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> 	Looks like memset() is zeroing wrong nr of bytes.
> > 
> > Good catch, however, I think we can just remove this memset altogether
> > since the memory gets allocated via kzalloc.
> 
> Correct, that memset() is superfluous.

Ok. Then this should do it.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/ibmveth.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.23-rc1-mm2-a/drivers/net/ibmveth.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/ibmveth.c	2007-08-06 23:32:13.000000000 +0200
@@ -963,7 +963,7 @@ static int __devinit ibmveth_probe(struc
 {
 	int rc, i;
 	struct net_device *netdev;
-	struct ibmveth_adapter *adapter = NULL;
+	struct ibmveth_adapter *adapter;

 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -997,7 +997,6 @@ static int __devinit ibmveth_probe(struc
 	SET_MODULE_OWNER(netdev);

 	adapter = netdev->priv;
-	memset(adapter, 0, sizeof(adapter));
 	dev->dev.driver_data = netdev;

 	adapter->vdev = dev;
