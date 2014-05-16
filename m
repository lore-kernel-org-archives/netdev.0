From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [BUG] might sleep functions in atomic context in stmmac_resume()
Date: Sat, 17 May 2014 03:15:54 +0400
Message-ID: <53769C2A.8050803@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: 1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are calls to might sleep functions in atomic context in
stmmac_resume():
- the first one is clk_prepare_enable(priv->stmmac_clk);
- the second one is stmmac_hw_setup()
-> init_dma_desc_rings()
  -> =EF=BB=BFstmmac_init_rx_buffers()
    -> __netdev_alloc_skb(GFP_KERNEL)

What is the purpose of spin_lock_irqsave(&priv->lock, flags) section?
What does it protect against?

=46ound by Linux Driver Verification project (linuxtesting.org).

--
Alexey Khoroshilov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
