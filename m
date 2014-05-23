From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 09:58:50 +0100
Message-ID: <537F0DCA.6030901@mentor.com>
References: <537E4AFD.20304@mentor.com>	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>	<1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>	<20140522.171033.1040508444998374401.davem@davemloft.net> <87ppj5vupf.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <linux-usb@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kamal@canonical.com>, <bhutchings@solarflare.com>,
	<edumazet@google.com>, <mszeredi@suse.cz>, <fw@strlen.de>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ppj5vupf.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But although the problem is the same, I believe the driver in question
> isn't the one I have been looking at recently.  The posted code snippet
> was from the NCM gadget driver (drivers/usb/gadget/f_ncm.c), isn't that
> right Jim?

Yes this is the NCM Gadget driver.
> 
> Yes, judging by this discussion I guess we should unconditionally copy
> instead of cloning in these drivers.  We'll always have bad
> payload/truesize ratio for cloned skbs, often less than 1/10 even for
> max size payload.
> 
> Actually, I thought we already did copy in the host cdc_ncm driver.  But
> I was wrong.  I was thinking of the cdc_mbim driver (which is different
> enough to have its own implementation of this part of the rx code). The
> cdc_ncm driver is cloning and the cdc_mbim driver is copying.  So we're
> not even consistent...
> 
> I'll create and test a patch for the cdc_ncm host driver unless someone
> else wants to do that. I haven't really played with the gadget driver
> before, so I'd prefer if someone knowing it (Jim maybe?) could take care
> of it.  If not, then I can always make an attempt using dummy_hcd to
> test it.
I can create a patch for the host driver, I will issue the gadget patch
first to resolve any issues, the fix would be similar.

> 
> BTW, wrt the data rates: These drivers are USB class drivers and we
> should really think of *all* possible rates, even future ones. This is
> not limited to 480 Mbps USB2. AFAICS, there isn't anything preventing
> the gadget driver from being used with e.g. a USB3380 controller to
> create a 5 Gbps NCM device.  I'm sure the future will bring us even
> faster USB devices.  The drivers will be the same.  Which is sort of
> beautiful and scaring at the same time :-)
> 
> But I assume the bad payload/truesize ratio is the most important factor
> here, so we should still copy?
I will test the copy implementation for any performance impact.


Jim
