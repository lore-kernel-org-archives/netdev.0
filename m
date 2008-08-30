From: David Fries <david@fries.net>
Subject: Re: [PATCH 1/2] ne.c fix, res->name
Date: Sat, 30 Aug 2008 13:05:03 -0500
Message-ID: <20080830180503.GI25161@spacedout.fries.net>
References: <20080830024425.GA24929@spacedout.fries.net> <20080831.000357.70223885.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:41963 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbYH3SFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 14:05:13 -0400
Content-Disposition: inline
In-Reply-To: <20080831.000357.70223885.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 31, 2008 at 12:03:57AM +0900, Atsushi Nemoto wrote:
> On Fri, 29 Aug 2008 21:44:25 -0500, David Fries <david@fries.net> wrote:
> > +	if (!strcmp(res->name, BAD_STR))
> > +		dev->mem_end = BAD;
> 
> The res->name might be NULL.  You should check it first.
> 
> 	if (res->name && !strcmp(res->name, BAD_STR))
> 		dev->mem_end = BAD;

The name gets a valid string by that point in time.

drivers/base/platform.c:257
int platform_device_add(struct platform_device *pdev)

        for (i = 0; i < pdev->num_resources; i++) {
                struct resource *p, *r = &pdev->resource[i];

                if (r->name == NULL)
                        r->name = pdev->dev.bus_id;

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)
