From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin
 Ethernet
Date: Thu, 9 Oct 2014 16:47:04 +0200
Message-ID: <20141009164704.7286fc3f@free-electrons.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20141009163315.2a9e1806@free-electrons.com>
	<54369EAC.5040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Antoine =?UTF-8?B?VMOpbmFydA==?=
	<antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54369EAC.5040301-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Sebastian Hesselbarth,

On Thu, 09 Oct 2014 16:41:48 +0200, Sebastian Hesselbarth wrote:

> > Hum, in mvneta, we already disabled the automatic negotiation and use
> > libphy. What makes you think the current mvneta driver is wrong in this
> > respect?
> 
> I didn't check mvneta, but remember Ezequiel didn't clear all AN bits
> in the barebox driver (which is based on Linux mvneta). Just mentioned
> that I'll have a closer look at it.

Ah, ok.

> But I agree, regarding libphy support mvneta is probably the best
> already.

Well, I initially remember that the original driver coming from Marvell
was using the HW PHY stuff, and that I changed that because it would
not integrate well with the kernel libphy.

A drawback of this is that because the hardware has built-in PHY
polling which triggers a MAC interrupt when the PHY status changes, they
typically don't wire up the PHY interrupt. Therefore, since we're not
able to use the MAC interrupt for PHY event notifications, we rely on
software PHY polling, which means that link up / link down events take
a few seconds to be noticed by the kernel. Unfortunately, I don't think
the hardware allows to use the hardware PHY polling to get link changes
interrupt, but not let the hardware configure the PHY itself.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
