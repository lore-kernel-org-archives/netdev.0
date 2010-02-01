From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3] sky2:  receive dma mapping error handling
Date: Mon, 1 Feb 2010 14:29:42 -0800
Message-ID: <20100201142942.710273cf@nehalam>
References: <20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
	<20100201102018.7b597992@nehalam>
	<20100201212740.GA3289@del.dom.local>
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
In-Reply-To: <20100201212740.GA3289@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Feb 2010 22:27:41 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> @@ -1038,13 +1035,14 @@ static void tx_init(struct sky2_port *sky2)
>  {
>  	struct sky2_tx_le *le;
>  
> -	sky2->tx_prod = sky2->tx_cons = 0;
> +	sky2->tx_prod = 0;
>  	sky2->tx_tcpsum = 0;
>  	sky2->tx_last_mss = 0;
>  
>  	le = get_tx_le(sky2, &sky2->tx_prod);
>  	le->addr = 0;
>  	le->opcode = OP_ADDR64 | HW_OWNER;
> +	sky2->tx_cons = sky2->tx_prod;
>  	sky2->tx_last_upper = 0;
>  }

Your change causes the initial element to be skipped. I want
it to goto the hardware. It makes sure the upper bits of the
first request are set (0).

I don't see what was wrong with my fix.

-- 
