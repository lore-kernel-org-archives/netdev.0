From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Mon, 02 Mar 2009 01:53:15 -0800 (PST)
Message-ID: <20090302.015315.181629191.davem@davemloft.net>
References: <20090301.201123.112634333.davem@davemloft.net>
	<20090301.202929.81587113.davem@davemloft.net>
	<1235980579.23967.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55953
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754544AbZCBJxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 04:53:30 -0500
In-Reply-To: <1235980579.23967.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Mon, 02 Mar 2009 02:56:19 -0500

> On Sun, 2009-03-01 at 20:29 -0800, David Miller wrote:
> > +
> > +	typhoon_fw_image = kmalloc(typhoon_fw->size, GFP_KERNEL);
> > +	if (!typhoon_fw_image) {
> > +		err = -ENOMEM;
> > +		goto out_err;
> >  	}
> 
> You never copied the image into the kmalloc'd memory, so you upload
> garbage.
> 
> Fix that and I think it will be OK.

Good catch, I've checked in the following fix:

typhoon: Add missing firmware copy.

Noticed by David Dillow.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/typhoon.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index ec2541c..9bba787 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1377,6 +1377,7 @@ typhoon_request_firmware(struct typhoon *tp)
 		err = -ENOMEM;
 		goto out_err;
 	}
+	memcpy(typhoon_fw_image, typhoon_fw->data, typhoon_fw->size);
 
 	return 0;
 
-- 
1.6.1.2.253.ga34a

