From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Mon, 1 Feb 2010 10:08:51 -0800
Message-ID: <20100201100851.01ac0b5f@nehalam>
References: <20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100131221835.GA3317@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 31 Jan 2010 23:18:35 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> @@ -1025,9 +1025,10 @@ static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
>  static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
>  {
>  	struct sky2_tx_le *le = sky2->tx_le + *slot;
> -	struct tx_ring_info *re = sky2->tx_ring + *slot;
> +	struct tx_ring_info *re;
>  
>  	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
> +	re = sky2->tx_ring + *slot;
>  	re->flags = 0;

Bogus, le and re are 1-to-1, so hardware portion an software
portion should be at same index.

-- 
