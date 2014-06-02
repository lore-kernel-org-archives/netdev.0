From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] stmmac: add DMA initialization delay to device tree
Date: Mon, 2 Jun 2014 19:14:09 +0000
Message-ID: <1401736448.2430.10.camel@abrodkin-8560l>
References: <1401720835-21507-1-git-send-email-abrodkin@synopsys.com>
	 <20140602.111543.1026699389707378851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "hdegoede@redhat.com" <hdegoede@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wens@csie.org" <wens@csie.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602.111543.1026699389707378851.davem@davemloft.net>
Content-Language: en-US
Content-ID: <9DCACED16E41174CA17D0AAD6E4F2880@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David,

On Mon, 2014-06-02 at 11:15 -0700, David Miller wrote:
> From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
> Date: Mon,  2 Jun 2014 18:53:55 +0400
> 
> > On some platforms existing 100 msecond delay is not enough for DMA block to
> > recover after reset.
> > For example MAC DMA waits for all PHY input clocks are present and depending
> > on the board reset bit deassertion may take different amount of time.
> > 
> > Having this parameter easily configurable allows each board to have its own
> > value, while all exisiting boards will continue to use current default value of
> > 100 msec.
> > 
> > Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> 
> Is there an upper bound for this you can just use?
> 
> It taking too long and timing out is an error condition, so just
> using a limit value of "100" or something should be perfectly fine.
> 
> I don't think it's reasonable to put every conceivable nuance into
> the DT nodes.

I understand that putting everything in DT is not a way to go.
But a rationale for this particular patch is as follows: as I may see up
until now everybody was happy with 100 milliseconds, but on my
particular board connected to Gbit network I see that more than a second
is required for DMA to initialize. If I connect the same board to 100
Mbit network then initialization delay could be up to 2.5 seconds.

So I may definitely bump the delay to say 3 seconds, but what if another
user needs even more?

On the other hand those who are happy now with 100 msec delay may be be
disappointed in case of failure and frozen for N seconds board waiting
for timeout.

If you think that delay for a few seconds in case of initialization
failure is acceptable then I will submit a patch that increases delay to
3 seconds (personally I haven't seen longer init times).

Regards,
Alexey
