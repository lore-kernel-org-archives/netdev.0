From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 1/2] [PATCH] ne.c fix rmmod, platform driver
 improvements
Date: Sun, 14 Sep 2008 00:29:06 +0900 (JST)
Message-ID: <20080914.002906.48532607.anemo@mba.ocn.ne.jp>
References: <20080913144457.GE28469@spacedout.fries.net>
	<20080914.001300.15242170.anemo@mba.ocn.ne.jp>
	<20080913151906.GG28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@gmail.com, akpm@linux-foundation.org,
	p_gortmaker@yahoo.com, alan@lxorguk.ukuu.org.uk, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: david@fries.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:58749 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbYIMP25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 11:28:57 -0400
In-Reply-To: <20080913151906.GG28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Sep 2008 10:19:06 -0500, David Fries <david@fries.net> wrote:
> > For now rbtx49xx ne platform devices use -1 for pdev->id, but it may
> > change.  Please don't assume it.
> 
> Does this work?
> -	if (0 <= this_dev && this_dev < MAX_NE_CARDS) {
> +	if (!res) {

It should work (not tested: I have no access to the board few days),
but if someone defined ne platform device with pdev->id == -1 and he
forgot to declare IO resources, but things happen.  Checking this_dev
range before accessing io[] array would be better.

---
Atsushi Nemoto
