From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: add DMA initialization delay to device tree
Date: Mon, 02 Jun 2014 13:45:35 -0700 (PDT)
Message-ID: <20140602.134535.1968359234490945809.davem@davemloft.net>
References: <1401720835-21507-1-git-send-email-abrodkin@synopsys.com>
	<20140602.111543.1026699389707378851.davem@davemloft.net>
	<1401736448.2430.10.camel@abrodkin-8560l>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hdegoede@redhat.com, netdev@vger.kernel.org, wens@csie.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	peppe.cavallaro@st.com, Vineet.Gupta1@synopsys.com
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401736448.2430.10.camel@abrodkin-8560l>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Mon, 2 Jun 2014 19:14:09 +0000

> I understand that putting everything in DT is not a way to go.
> But a rationale for this particular patch is as follows: as I may see up
> until now everybody was happy with 100 milliseconds, but on my
> particular board connected to Gbit network I see that more than a second
> is required for DMA to initialize. If I connect the same board to 100
> Mbit network then initialization delay could be up to 2.5 seconds.
> 
> So I may definitely bump the delay to say 3 seconds, but what if another
> user needs even more?
> 
> On the other hand those who are happy now with 100 msec delay may be be
> disappointed in case of failure and frozen for N seconds board waiting
> for timeout.
> 
> If you think that delay for a few seconds in case of initialization
> failure is acceptable then I will submit a patch that increases delay to
> 3 seconds (personally I haven't seen longer init times).

Stop right there.

We are doing synchronous delays here, without sleeping, and if that takes
seconds it is totally unacceptable.

You'll first have to convert this code to use msleep() or similar.

Second, if the chip hangs nobody cares if there is a 3 second pause, it's
error recovery.
