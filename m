From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Sun, 18 Apr 2010 20:50:21 +0100
Message-ID: <1271620221.3679.265.camel@localhost>
References: <1271611557.24099.11.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37481 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab0DRTu0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 15:50:26 -0400
In-Reply-To: <1271611557.24099.11.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-18 at 19:25 +0200, Richard R=C3=B6jfors wrote:
> This patch adds a module parameter for setting the MAC address.
>=20
> To ensure this MAC address is used, the MAC address is written
> after each hardware reset.
[...]

This is not an accepted way of setting the MAC address.  The accepted
ways to initialise a network controller's address are:

1. a. Controller reads it from dedicated NVRAM.  Driver reads it from
      controller.
   b. Driver reads it from dedicated NVRAM.
2. Platform firmware or boot loader passes platform data (OpenFirmware,
   device tree, etc.) to the kernel, which includes the assigned MAC
   address.  Driver uses kernel functions to read it from platform data=
=2E
3. Platform firmware or boot loader programs it into the controller.
   Driver reads it from the controller.
4. Driver generates random address.

In any case, userland can change the MAC address later.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

