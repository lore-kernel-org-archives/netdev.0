From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] 6lowpan: Sync default hardware address of lowpan links
 to their wpan
Date: Sun, 6 Oct 2013 02:24:52 +0200
Message-ID: <20131006002451.GA22623@omega>
References: <1381009080-15945-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381009080-15945-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan,

On Sat, Oct 05, 2013 at 05:38:00PM -0400, Alan Ott wrote:
> When a lowpan link to a wpan device is created, set the hardware address
> of the lowpan link to that of the wpan device.
> 
> Signed-off-by: Alan Ott <alan@signal11.us>
> ---
>  net/ieee802154/6lowpan.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index c85e71e..fb89133 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -1386,6 +1386,9 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
>  
>  	entry->ldev = dev;
>  
> +	BUG_ON(IEEE802154_ADDR_LEN != dev->addr_len);
So if somebody make a:
"ip link add link $NOT_8BYTE_HWADDR_DEV name $NAME type lowpan"

the kernel creates a BUG_ON? Okay it seems that case is very unusual but
better is to return a errno so "maybe(I don't know it)" the userspace
software will generate a error and the whole kernel doesn't crash.

> +	memcpy(dev->dev_addr, real_dev->dev_addr, IEEE802154_ADDR_LEN);
Is there one case where we read the dev->dev_addr? I saw a case when we
set this [1], but I don't know why we need this. Did you detect some
problems because this isn't the "real" hw addr?

Other case is I am feeling uneasy when we have two netdev devices with
the same hw addr.

- Alex

[1] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net/ieee802154/6lowpan.c?id=refs/tags/v3.12-rc3#n1102
