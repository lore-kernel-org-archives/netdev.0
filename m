From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: build_skb() and data corruption
Date: Tue, 14 Jan 2014 16:51:34 +0100
Message-ID: <201401141651.34633.arnd@arndb.de>
References: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com> <1389620539.3720.157.camel@deadeye.wl.decadent.org.uk> <CACmBeS1gTfdjwiCkHMViOnF6G2zjy3HSMm3NVq8Jiq5F22ynJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	alexander.h.duyck@intel.com,
	Florian Fainelli <florian@openwrt.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACmBeS1gTfdjwiCkHMViOnF6G2zjy3HSMm3NVq8Jiq5F22ynJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 January 2014, Jonas Jensen wrote:
> Thanks for the replies, you led me to a new solution,
> 
> 
> I now think build_skb() is not the right choice, my motivation for
> using it in the first place, that I thought it meant getting away with
> not copying memory.
> 
> build_skb() is replaced by netdev_alloc_skb_ip_align() and memcpy()
> (derived from drivers/net/ethernet/realtek/r8169.c).
> 
> Read errors are gone, even without syncing DMA. Is it a good idea to
> do it anyway, i.e. leave calls to dma_sync_single_* in?

The calls to dma_sync_single_* in the moxart_rx() function are needed.
The call to arm_dma_ops.sync_single_for_device() in
moxart_mac_setup_desc_ring() is wrong, because the buffer is already
owned by the device at that point (just after dma_map_single), and
because you should use the official dma_* api rather than using
the arm_dma_ops struct.

	Arnd
