From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC PATCH 1/2] smsc911x: add support for sh3 RX DMA
Date: Mon, 24 Nov 2008 12:42:37 +0900
Message-ID: <20081124034237.GB26414@linux-sh.org>
References: <1227456274-10388-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta23.gyao.ne.jp ([125.63.38.249]:42534 "EHLO mx.gate01.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750862AbYKXDn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 22:43:56 -0500
Content-Disposition: inline
In-Reply-To: <1227456274-10388-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2008 at 04:04:33PM +0000, Steve Glendinning wrote:
> I've been working on adding DMA support to the smsc911x driver.  As this 
> family of devices is non-pci, DMA transfers must be initiated and 
> controlled by the host CPU.  Unfortunately this makes some of the code 
> necessarily platform-specific.
> 
> This patch adds RX DMA support for the sh architecture.  Tested on 
> SH7709S (sh3), where it gives a small (~10%) iperf tcp throughput 
> increase.  DMA or PIO is selected at compile-time.
> 
> My first attempt stopped NAPI polling during a DMA transfer, then used 
> DMA completion interrupts to pass the packet up and re-enable polling.
> Obviously this defeats the interrupt-mitigation of NAPI, and on my test 
> platform actually *reduced* performance!
> 
> This patch leaves NAPI polling enabled, so a later poll completes the 
> transfer.  I'm concerned this is essentially busy-waiting on the 
> transfer, but it does show a small performance gain.  Is this a good or 
> bad idea?
> 
> I'd be interested to hear if anyone has advice on how to make this 
> patch more generic.  There's definitely been interest from arm pxa
> users in adding DMA, and some of this code must be re-usable for this.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

The intent was to move everything over to the dmaengine framework and
have drivers (especially generic ones) opt for using that instead. This
hasn't happened yet, but it doesn't seem like there is much point in
adding hacks to the smsc911x driver at present given the overhead
involved in the interrupt handling. While this is something that can
easily be improved, I would rather put more effort in to getting things
moved over to the generic frameworks now that they exist, and optimize
later.
