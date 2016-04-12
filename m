From: Stefan Agner <stefan@agner.ch>
Subject: Re: Configuring ethernet link fails with No such device
Date: Tue, 12 Apr 2016 00:25:02 -0700
Message-ID: <ed0d524976663f40412b1852e16099f8@agner.ch>
References: <67b662523c63277fa95a59472cbf018f@agner.ch>
 <20160411.212900.1164760179761034053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: systemd-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	u.kleine-koenig@pengutronix.de, bryan.wu@canonical.com,
	bob.ham@collabora.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:47035 "EHLO
	mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbcDLH2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 03:28:24 -0400
In-Reply-To: <20160411.212900.1164760179761034053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-04-11 18:29, David Miller wrote:
> From: Stefan Agner <stefan@agner.ch>
> Date: Mon, 11 Apr 2016 15:46:08 -0700
> 
>> What is the expectation/definition when link configuration should be
>> possible? Only after the network device got opened or before?
> 
> Only after it is open.  Drivers almost always have the entire chip in
> powerdown state when it is not open, so we wouldn't be able to
> properly do link settings even if we wanted to when the device is
> closed.

I see. Afact it is a udev rule which triggers the built-in link setup
code:
https://github.com/systemd/systemd/blob/09541e49ebd17b41482e447dd8194942f39788c0/rules/80-net-setup-link.rules

The udev rule is triggering on action add (=> probe on driver level). At
least on the device I tested, it seems that there is no event on open...
Any other ideas what could be used as trigger to configure the link?
