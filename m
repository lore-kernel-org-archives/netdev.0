From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 2/3] net: Add Keystone NetCP ethernet driver
Date: Tue, 30 Sep 2014 13:09:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174A1012@AcuExch.aculab.com>
References: <1411667317-1163-1-git-send-email-santosh.shilimkar@ti.com>
	<1411667317-1163-3-git-send-email-santosh.shilimkar@ti.com>
 <20140929.155200.2231132602322345812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"sandeep_n@ti.com" <sandeep_n@ti.com>,
	"joe@perches.com" <joe@perches.com>
To: 'David Miller' <davem@davemloft.net>,
	"santosh.shilimkar@ti.com" <santosh.shilimkar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55428 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751038AbaI3NLW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:11:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03621-08 for <netdev@vger.kernel.org>;
 Tue, 30 Sep 2014 14:11:14 +0100 (BST)
In-Reply-To: <20140929.155200.2231132602322345812.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date: Thu, 25 Sep 2014 13:48:36 -0400
> 
> > +static inline int gbe_phy_link_status(struct gbe_slave *slave)
> > +{
> > +	if (!slave->phy)
> > +		return 1;
> > +
> > +	if (slave->phy->link)
> > +		return 1;
> > +
> > +	return 0;
> > +}
> 
> Please use 'bool' as the return type and return 'true' or 'false'.

That function body could also be just:
	return !slave->phy && slave->phy->link;
which might be more readable if directly coded.

I also wonder if slave>phy can actually be NULL?
If it can be under unusual circumstances it might be worth
assigning the address of a dummy 'phy' structure so that the
tests can all be removed.

	David
