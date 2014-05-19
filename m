From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [BUG] might sleep functions in atomic context in stmmac_resume()
Date: Mon, 19 May 2014 08:57:25 +0200
Message-ID: <5379AB55.2050003@st.com>
References: <53769C2A.8050803@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53769C2A.8050803@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexey

On 5/17/2014 1:15 AM, Alexey Khoroshilov wrote:
> There are calls to might sleep functions in atomic context in
> stmmac_resume():
> - the first one is clk_prepare_enable(priv->stmmac_clk);
> - the second one is stmmac_hw_setup()
> -> init_dma_desc_rings()
>    -> =EF=BB=BFstmmac_init_rx_buffers()
>      -> __netdev_alloc_skb(GFP_KERNEL)
>
> What is the purpose of spin_lock_irqsave(&priv->lock, flags) section?
> What does it protect against?

Some part of this driver, especially on PM stuff, has been reworked
time ago.
I have in plan to do further tests and investigations
also to understand and try to solve this kind of issues. I do not
want to see this kind of BUGs. Also I have some other patches on
other pending problem I will submit to be reviewed.
I hope to start doing this task in the incoming days.

BR
peppe

>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> --
> Alexey Khoroshilov
> Linux Verification Center, ISPRAS
> web: http://linuxtesting.org
>
>
