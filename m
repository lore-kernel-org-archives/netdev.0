From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH net-next v3 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Thu, 8 Dec 2016 10:59:47 +0100
Message-ID: <19ff9840-62cb-0de1-9d3d-f1312cfaf715@atmel.com>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
 <20161207193908.GA13062@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <harinikatakamlinux@gmail.com>, <harini.katakam@xilinx.com>,
        <punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>,
        <rafalo@cadence.com>
To: Richard Cochran <richardcochran@gmail.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207193908.GA13062@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 07/12/2016 à 20:39, Richard Cochran a écrit :
> On Wed, Dec 07, 2016 at 08:21:51PM +0200, Andrei Pistirica wrote:
>> +#ifdef CONFIG_MACB_USE_HWSTAMP
>> +void gem_ptp_init(struct net_device *ndev);
>> +void gem_ptp_remove(struct net_device *ndev);
>> +
>> +void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb);
>> +void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb);
> 
> These are in the hot path, and so you should do the test before
> calling the global function, something like this:
> 
> void gem_ptp_txstamp(struct macb *bp, struct sk_buff *skb);
> 
> static void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb)
> {
> 	if (!bp->hwts_tx_en)
> 		return;
> 	gem_ptp_txstamp(bp, skb);
> }
> 
> Ditto for Rx.

Hi Richard,

So you mean that as the "global" function won't be "inlined" by the
compiler as the function is not "static" neither in the same file and
that the jump will be implemented anyway. And this even if the function
is only called at a single location...

This way, if we add a kind or accessors function like the one that you
propose, with the test in it, the branch prediction can play his role
without breaking the processor pipeline as the accessors function will
be inlined by the compiler: Am I right?

So, yes, makes sense. Thanks for the hint.

Regards,
-- 
Nicolas Ferre
