From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Missing return check against Null for return value of
 netdev_alloc_dev_skb()
Date: Sun, 15 Jun 2014 19:26:35 -0700 (PDT)
Message-ID: <20140615.192635.533361731164638772.davem@davemloft.net>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
	<20140614.235300.1228145928404410306.davem@davemloft.net>
	<CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xerofoify@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbaFPC0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 22:26:39 -0400
In-Reply-To: <CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Krause <xerofoify@gmail.com>
Date: Sun, 15 Jun 2014 16:27:23 -0400

> From 62b0d77a1430f74b7f5c008c5e8bec11604b33b0 Mon Sep 17 00:00:00 2001
> From: Nick <xerofoify@gmail.com>
> Date: Sun, 15 Jun 2014 16:16:14 -0400
> Subject: [PATCHv2] Fixes return logic of function of pch_gbe_alloc_tx_buffers()
> Here is the fixed patch changed return type of function to int in
> order to use return -ENOMEM as with the function above it , seems to
> fit , otherwise returns 0.
>  Report if it breaks anything related to this driver.
> Signed-off-by: Nick <xerofoify@gmail.com>

Nobody is checking the return value, you can't just change the function to
return an error code, you have to make the caller act upon it appropriately
as well.

I'm very much not confident that you are willing to put in the effort
necessary to fix this problem properly.

I told you explicitly that if this memory allocation failure occurs, the
bringup of the device has to fail.

Your patch is making the situation worse, it breaks when there is an
allocation failure, leaving the TX run partially allocated so that the
driver will crash with an OOPS later.

>From your first iteration, you aren't build testing this change, and I
therefore severely doubt you are functionally testing this change either.

I hate to be harsh, but this is an extremely _poor_ patch submission.
