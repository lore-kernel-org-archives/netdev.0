From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Using net_devices with ATM/DSL
Date: Mon, 13 Dec 2010 13:50:09 +0100
Message-ID: <201012131350.10206.florian@openwrt.org>
References: <4D05C2D3.7010306@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57261 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042Ab0LMMu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 07:50:28 -0500
Received: by wyb28 with SMTP id 28so5852570wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 04:50:27 -0800 (PST)
In-Reply-To: <4D05C2D3.7010306@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Monday 13 December 2010 07:53:07 Philip Prindeville wrote:
> I was trying to get this discussion rolling on linux-atm-general but didn't
> have much luck.
> 
> I was wondering what the downside to having ATM/DSL interfaces use
> net_devices would be?

I think you would have to add ATM/DSL-specific extensions (ala wext) just to 
extend it, specializing an atm_dev would make more sense to me.

> 
> Part of the reason for wanting to do this is to have an end-point to
> send/receive netlink messages to, so that the interface can report carrier
> state transitions, bit rates, bit-error rates, SNR, attenuation,
> constellations, transmitter gain, etc.
> 
> Seems simple enough.

If you want to be able to report informations from the DSL PHY, I would rather 
specialize an interface called, say dsl_phy which has a list of operations for 
setting/getting the DSL PHY state, low-level counters ... 

The atm stack more or less already supports an ATM PHY with 
atmphy_ops, but is in my opinion too limited to query chip-speficic infos.

Once that interface is well defined, adding netlink support to it should be 
rather straight forward.

> 
> Why not do this?
> 
> Thanks,
> 
> -Philip
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
