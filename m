From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: thunderx: Set recevie buffer page usage count
 in bulk
Date: Mon, 07 Mar 2016 12:04:10 -0500 (EST)
Message-ID: <20160307.120410.1851177945150642006.davem@davemloft.net>
References: <1457336157-31508-2-git-send-email-sunil.kovvuri@gmail.com>
	<20160307.111534.235286977900488968.davem@davemloft.net>
	<CA+sq2CewOQGSiRC5m64ioYS36-WO0C5XzykZRZd+OLE1tJ-sSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbcCGREM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:04:12 -0500
In-Reply-To: <CA+sq2CewOQGSiRC5m64ioYS36-WO0C5XzykZRZd+OLE1tJ-sSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Date: Mon, 7 Mar 2016 22:28:39 +0530

> Hi David,
> 
>>> you create a window of time during which the consumer
>>> can release the page and prematurely free it.
> Okay, but here the consumer i.e HW is notified only after page count
> is incremented.
> For example if you check 'nicvf_refill_rbdr' fn() only after receive
> buffer ring is
> refilled with buffers, doorbell is issued to hardware to start using
> the new buffers.
> 
> So
> @@ -241,6 +254,8 @@ refill:
>                 new_rb++;
>         }
> 
> +       nicvf_get_page(nic);
> +
> calling 'nicvf_get_page' before issuing doorbell ensures page ref
> count is properly
> set before hw/consumer can use the buffers.

So if you know ahead of time how the page will be split up, just
calculate that when you get the page and increment the page count
appropriately.

That's what we do in the NIU driver.
