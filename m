From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Mon, 11 Nov 2013 17:43:26 -0800
Message-ID: <CAGVrzcYji=tmNzvu8cUSU_P27BrGZBvFowC3NdnM2UvRpRsvmQ@mail.gmail.com>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1378480701-12908-4-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:54519 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab3KLBoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 20:44:08 -0500
In-Reply-To: <1378480701-12908-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/9/6 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:

> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".
> +
> +Such a fixed link situation is described by creating a PHY node as a
> +sub-node of an Ethernet device, with the following properties:
> +
> +* 'fixed-link' (boolean, mandatory), to indicate that this PHY is a
> +  fixed link PHY.
> +* 'speed' (integer, mandatory), to indicate the link speed. Accepted
> +  values are 10, 100 and 1000

'max-speed' might be better here to match ePAPR v1.1 (if we do care,
'speed') works for me too.

> +* 'full-duplex' (boolean, optional), to indicate that full duplex is
> +  used. When absent, half duplex is assumed.
> +* 'pause' (boolean, optional), to indicate that pause should be
> +  enabled.
> +* 'asym-pause' (boolean, optional), to indicate that asym_pause should
> +  be enabled.

We also need to add a property: 'connection-type' which can be any of
'mii', 'rgmii' etc... When operating Ethernet devices with Ethernet
devices connected back to back, it might be required to configure the
Ethernet MAC with an appropriate connection type.

Note that I picked 'connection-type' here because this the ePAPR v1.1
terminology. Now the good thing is that it is a new "feature" wrt. the
old binding.
