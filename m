From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Discard masked flags in interrupt status
 register
Date: Sun, 29 Jan 2017 18:15:41 -0500 (EST)
Message-ID: <20170129.181541.423447436903187089.davem@davemloft.net>
References: <1485519883-24969-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        peppe.cavallaro@st.com, fabrice.gasnier@st.com, manabian@gmail.com,
        preid@electromag.com.au, alexandre.torgue@gmail.com,
        Vineet.Gupta1@synopsys.com
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485519883-24969-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Fri, 27 Jan 2017 15:24:43 +0300

> DW GMAC databook says the following about bits in "Register 15 (Interrupt
> Mask Register)":
> --------------------------->8-------------------------
> When set, this bit __disables_the_assertion_of_the_interrupt_signal__
> because of the setting of XXX bit in Register 14 (Interrupt
> Status Register).
> --------------------------->8-------------------------
> 
> In fact even if we mask one bit in the mask register it doesn't prevent
> corresponding bit to appear in the status register, it only disables
> interrupt generation for corresponding event.
> 
> But currently we expect a bit different behavior: status bits to be in
> sync with their masks, i.e. if mask for bit A is set in the mask
> register then bit A won't appear in the interrupt status register.
> 
> This was proven to be incorrect assumption, see discussion here [1].
> That misunderstanding causes unexpected behaviour of the GMAC, for
> example we were happy enough to just see bogus messages about link
> state changes.
> 
> So from now on we'll be only checking bits that really may trigger an
> interrupt.
> 
> [1] https://lkml.org/lkml/2016/11/3/413
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

This looks good, applied, thanks.
