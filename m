From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v1 17/21] amd-xgbe: Add I2C support for
 determining SFP media types
Date: Thu, 3 Nov 2016 16:18:48 +0100
Message-ID: <20161103151848.GD1768@lunn.ch>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103133036.3437.71231.stgit@tlendack-t1.amdoffice.net>
 <20161103142815.GB1768@lunn.ch>
 <1af561af-65e2-8422-1901-d4b1c317ad12@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35626 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754355AbcKCPSv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 11:18:51 -0400
Content-Disposition: inline
In-Reply-To: <1af561af-65e2-8422-1901-d4b1c317ad12@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are a couple of things about this. Russel's work isn't part of
> the kernel yet so I can't make use of it.

Well, you could guide it into the kernel. Part of it has already made
the way in. And i know of other platforms which would benefit from it.

> Additionally, the I2C device is integrated into the IP of the
> network device with register addresses being offsets of the network
> device BAR so I'm not sure how I would go about getting it setup in
> order to use the i2c infrastructure.

Have you looked at the core i2c stuff? All you need is an
i2c_algorithim structure:

http://lxr.free-electrons.com/source/include/linux/i2c.h#L407

and an i2c_adaptor structure:

http://lxr.free-electrons.com/source/include/linux/i2c.h#L532

and then you can call i2c_add_adapter() to register your i2c bus with
the i2c core. Embedded such an i2c driver inside another driver is not
a problem.

  Andrew
