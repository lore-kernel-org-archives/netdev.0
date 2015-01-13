From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/8] net: dsa: make module builds work
Date: Tue, 13 Jan 2015 16:38:53 -0500 (EST)
Message-ID: <20150113.163853.1503595006355422756.davem@davemloft.net>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
	<1421099866-3184-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbAMVi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:38:56 -0500
In-Reply-To: <1421099866-3184-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 12 Jan 2015 13:57:40 -0800

> Building any DSA driver as a module will work from a compilation/linking
> perspective, but the resulting modules produced are not functional.
> 
> Any DSA driver references register_switch_driver and
> unregister_switch_driver which are provided by net/dsa/dsa.c, so loading
> any of these modules prior to dsa_core.ko being loaded will faill.
> 
> Unfortunately, loading dsa_core.ko will make us call dsa_switch_probe()
> which will find no DSA switch driver and return an error so we are stuck
> there because there is no switch driver available. So this is getting us
> nowhere.
> 
> This patch introduces a separate module, named dsa_lib which contains
> register_switch_driver, unregister_switch_driver and dsa_switch_probe
> (to avoid exposing the list and mutex used for walking switch drivers),
> such that the following can be done:
> 
> - load dsa_lib
> - load the dsa switch driver, e.g: mv88e6060, bcm_sf2
> - load the dsa_core module
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

This looks worse to me.

Really, the match table and probing should not be in dsa_core at all.

It should only be done in individual drivers.
