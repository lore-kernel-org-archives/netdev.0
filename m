From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH V8 12/13] ptp: Added a clock driver for the IXP46x.
Date: Mon, 10 Jan 2011 21:24:15 +0100
Message-ID: <m31v4kpkwg.fsf@intrepid.localdomain>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	<8151196c018776704df34748f333bdb159497d0b.1293820862.git.richard.cochran@omicron.at>
	<m3ei8plpa0.fsf@intrepid.localdomain>
	<20110107170752.GB8666@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110107170752.GB8666-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org> (Richard Cochran's
	message of "Fri, 7 Jan 2011 18:07:52 +0100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> But before that, I have a big favor to ask you. Can you please look at
> the TODO in my patch and give me a hint? I don't know how to relate
> the port instance (NPE A,B,C) to the two time stamping channels.

I assume you mean this:
+ * PHYSICAL_ID(p->id) ?
+ * TODO - Figure out correct mapping.

Unfortunately I can's find this information in the devel manual. I think
there are 3 channels (not two), each for one Ethernet port. IXP465 can
have a port on each NPE.

PHYSICAL_ID etc. are described at the start of the file:
 * logical port         0x00            0x10            0x20
 * NPE                  0 (NPE-A)       1 (NPE-B)       2 (NPE-C)
 * physical PortId      2               0               1

This means the first port (usually "eth0") is connected to NPE-B, the
second port to NPE-C, and the third port to NPE-A (not available on
IXP42x).

Also, the manual says NPE-B can serve 3 additional Ethernet ports
(6 total).

I only have access to IXP425 (and 421) hardware. I think someone with
the actual IXP465 has to check the details.
-- 
Krzysztof Halasa
