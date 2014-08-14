From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 0/3] enic: Add support for rx_copybreak
Date: Thu, 14 Aug 2014 09:34:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17477B95@AcuExch.aculab.com>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50114 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752368AbaHNJgr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:36:47 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04273-09 for <netdev@vger.kernel.org>;
 Thu, 14 Aug 2014 10:36:38 +0100 (BST)
In-Reply-To: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan
> dma_map_single()/dma_unmap_single() is more expensive than alloc_skb & memcpy
> for smaller packets. By doing this we can reuse the dma buff which is already
> mapped. This is very useful when iommu is on. The default skb copybreak value
> is 256.
> 
> When iommu is on, we can go much higher than 256. All the drivers that supports
> rx_copybreak provides module parameter to change this value. Since module
> parameter is the least preferred way for changing driver values, this series
> adds ethtool support for setting rx_copybreak.

Is there any mileage in having a system-wide default for rx_copybreak?
I'd have thought that the value is really driver independent since it
(mostly) depends on the comparative cost of dma_map and copy operations.

The same also applies to any equivalent copy done during transmit.
(Not sure if I've seen any drivers that keep a permanently mapped
buffer for transmitting small fragments.)

	David
