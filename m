From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 13/17] net: stmmac: Implement NAPI for TX
Date: Tue, 31 Jan 2017 14:38:46 +0100
Message-ID: <20170131133846.GA10939@Red>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-14-clabbe.montjoie@gmail.com>
 <cd8b200c-f419-80c3-714e-cb81a95da65c@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.torgue@st.com, netdev@vger.kernel.org,
        davem@davemloft.net, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36433 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752192AbdAaNlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 08:41:03 -0500
Content-Disposition: inline
In-Reply-To: <cd8b200c-f419-80c3-714e-cb81a95da65c@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 11:28:03AM +0100, Giuseppe CAVALLARO wrote:
> On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> > The stmmac driver run TX completion under NAPI but without checking the
> > work done by the TX completion function.
> >
> > This patch add work/budget to the TX completion function.
> >
> > The visible effect is that it keep the driver longer under NAPI and
> > boost performance.
> > Under dwmac-sun8i the iperf goes from 140Mbit/s to 500Mbit/s.
> > Under dwmac-sunxi an iperf run use half less interrupts.
> 
> I think that this patch should be sent separately with more details
> about the implementation you are adopting and results.
> 

This patch is just implementing what NAPI documentation say.
"The budget parameter places a limit on the amount of work the driver may do. Each received packet counts as one unit of work. The poll() function may also process TX completions, in which case if it processes the entire TX ring then it should count that work as the rest of the budget. Otherwise, TX completions are not counted."

For the history, I have done the sun8i-emac driver for H3/A64 and get with if very good performance.
Some people find that the hardware was in fact a modified version of dwmac and so I start working on dwmac-sun8i glue driver.
Testing dwmac-sun8i give very bad performance and the only real difference between thoses two driver was the handling of NAPI TX mitigation.

The performance are tested with a simple iperf.
I will redo some test with some numbers

> For example, in the timer callback you force 256 (it seems
> DMA_TX_SIZE/2); do you think this should be tunable or fixed to
> NAPI budget?

I think that the whole "TX mitigation timer" is useless when using TX completion within NAPI.
I will do some bench for checking with and without it.

> 
> I'd like to understand if performance you get are for TCP traffic;
> can you tell me what happens on unidirectional traffic?
> 
> Thx a lot for your effort, pls let me know
> 
> Regards
> peppe
> 
