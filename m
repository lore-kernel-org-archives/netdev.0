From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction
 item queue for attr_set and obj_add
Date: Thu, 24 Sep 2015 22:55:08 -0700 (PDT)
Message-ID: <20150924.225508.2124748200966556070.davem@davemloft.net>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
	<20150925043640.GB18915@ketchup.lan>
	<CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
	netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	f.fainelli@gmail.com, linux@roeck-us.net, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, jiri@mellanox.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbIYFzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 01:55:09 -0400
In-Reply-To: <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Thu, 24 Sep 2015 22:29:43 -0700

> I'd rather keep 2-phase not optional, or at least make it some what of
> a pain for drivers to opt-out of 2-phase.  Forcing the driver to see
> both phases means the driver needs to put some code to skip phase 1
> (and hopefully has some persistent comment explaining why its being
> skipped).  Something like:
> 
> /* I'm skipping phase 1 prepare for this operation.  I have infinite hardware
>  * resources and I'm not setting any persistent state in the driver or device
>  * and I don't need any dynamic resources from the kernel, so its impossible
>  * for me to fail phase 2 commit.  Nothing to prepare, sorry.
>  */

I agree with Scott here.

If you can opt out of something, you can not think about it and thus
more likely get it wrong.

I can just see a driver not implementing prepare at all and then doing
stupid things in commit when they hit some resource limit or whatever,
rather than taking care of such issues in prepare.
