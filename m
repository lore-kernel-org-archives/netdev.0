From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: PING: [PATCH] net: smsc911x: Reset PHY during initialization
Date: Wed, 11 Nov 2015 10:05:24 +0300
Message-ID: <009b01d11c4f$57f6ef10$07e4cd30$@samsung.com>
References: <006801d11b82$1f5704b0$5e050e10$@samsung.com>
 <20151110.115149.604622279273759756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	steve.glendinning@shawell.net
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20151110.115149.604622279273759756.davem@davemloft.net>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

> If you think I should reconsider the patch, you should resubmit it.

 I understand this, of course. But, before doing this i'd like to
clarify your concern, why exactly you think that loopback test will
break. Because the (simplified) algorithm is:

do {
    result = loopback_test()
    if (result == failed)
        reset_phy()
} while (result == ok)

 So, if loopback test works for the first time, PHY reset will never
be done. So, the conclusion is: in real situation it is never used at all.
 Conclusion no 2, coming from my tests: if loopback test fails, phy reset
actually does not fix it. So, perhaps, it's not needed there at all.

 I understand, that some other boards might behave differently, and loopback test was written this very way for some reason. Also, i
understand that you, as a maintainer, have rights for the final decision. And in order to rework the patch, i'd like to discuss with
you, which rework you would prefer. I came up with three possibilities:
--- cut ---
 a) Leave PHY reset inside loopback test as it is, but add a second routine and call it only before smsc911x_soft_reset().
 b) Reset PHY only conditionally, using the following algorithm:
    if smsc911x_soft_reset() {
        /* NIC reset failed, kick the PHY and retry */
        smsc911x_phy_reset()
        if (smsc_911x_soft_reset())
            return -ENODEV;
    }
 c) Do extra PHY reset only if some hint in device tree is specified (or the machine is known to have the problem)
--- cut ---
 I can even try to guess your thoughts (because you never elaborated them for me):

 1. loopback test will break because PHY has been reset before. In this case, (b) or (c) is a way to go.
 2. loopback test will break because of reset method change. In this case (a) is the way to go.

 So, what do you really think?

 BTW, where is Steve, whose address is specified in MAINTAINERS for this code? Is it abandonware?

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
