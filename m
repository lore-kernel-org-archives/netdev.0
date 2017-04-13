From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: set total length of the packet
 to be transmitted in TDES3
Date: Thu, 13 Apr 2017 12:40:23 -0400 (EDT)
Message-ID: <20170413.124023.506336754463093992.davem@davemloft.net>
References: <20170410183329.28847-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, niklass@axis.com
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410183329.28847-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 10 Apr 2017 20:33:29 +0200

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> Field FL/TPL in register TDES3 is not correctly set on GMAC4.
> TX appears to be functional on GMAC 4.10a even if this field is not set,
> however, to avoid relying on undefined behavior, set the length in TDES3.
> 
> The field has a different meaning depending on if the TSE bit in TDES3
> is set or not (TSO). However, regardless of the TSE bit, the field is
> not optional. The field is already set correctly when the TSE bit is set.
> 
> Since there is no limit for the number of descriptors that can be
> used for a single packet, the field should be set to the sum of
> the buffers contained in:
> [<desc with First Descriptor bit set> ... <desc n> ...
> <desc with Last Descriptor bit set>], which should be equal to skb->len.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, thanks.
