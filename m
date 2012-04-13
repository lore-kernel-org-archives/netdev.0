From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2: in free_buffers() do proper checks before call of
 rx_clean()
Date: Fri, 13 Apr 2012 10:09:54 -0700
Message-ID: <20120413100954.6fdc0f5c@nehalam.linuxnetplumber.net>
References: <20120403001327.GB10227@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403001327.GB10227@Neptun>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Apr 2012 02:13:27 +0200
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> In sky2_open() free_buffers() is called in case that alloc_buffers() failed.
> Here we do the check for sky2->rx_le too late, since we already called
> rx_clean() which accessed rx_le. Furthermore we lack a check for sky2->rx_ring
> which is also accessed by rx_clean().
> 
> With this patch both sky2->rx_le and sky2->rx_ring are checked before
> alloc_buffers() is called.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Looking at sky2_alloc_buffers, it really needs to change to have
proper unwind instead. If some portion of the memory required isn't available
everything needs to be undone.
