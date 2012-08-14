From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 3/5] net/mlx4_en: Call netif_carrier_off() after
 register_netdev()
Date: Tue, 14 Aug 2012 12:36:12 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C066A09@CMEXMB1.ad.emulex.com>
References: <1344940135-17079-1-git-send-email-shchepetkov@ispras.ru>
 <1344940135-17079-4-git-send-email-shchepetkov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <amirv@mellanox.com>,
	<ogerlitz@mellanox.com>, <alexg@mellanox.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ldv-project@ispras.ru>
To: <shchepetkov@ispras.ru>, <yevgenyp@mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344940135-17079-4-git-send-email-shchepetkov@ispras.ru>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Ilya Shchepetkov
>
>For carrier detection to work properly when binding the driver with a
>cable unplugged, netif_carrier_off() should be called after
>register_netdev(), not before.
>
>Calling netif_carrier_off() before register_netdev() was causing the
>network interface to miss a linkwatch pending event leading to an
>inconsistent state if the link is not up when interface is initialized.

ndo_open() may be called as soon register_netdev() completes...
When netif_carrier_off() is called *after* register_netdev(), isn't there
a possibility of a ndo_open()->netif_carrier_on() call racing this call, causing
incorrect results?
