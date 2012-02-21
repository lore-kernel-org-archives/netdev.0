From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/4] br_device: unify return value of
 .ndo_set_mac_address if address is invalid
Date: Tue, 21 Feb 2012 09:22:13 -0800
Message-ID: <20120221092213.12015034@nehalam.linuxnetplumber.net>
References: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
	<1329826072-14689-5-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329826072-14689-5-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Feb 2012 13:07:52 +0100
Danny Kukawka <danny.kukawka@bisect.de> wrote:

> Unify return value of .ndo_set_mac_address if the given address
> isn't valid. Return -EADDRNOTAVAIL as eth_mac_addr() already does
> if is_valid_ether_addr() fails.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  net/bridge/br_device.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index a157bf8..ba829de 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -167,7 +167,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
>  	struct sockaddr *addr = p;
>  
>  	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EINVAL;
> +		return -EADDRNOTAVAIL;
>  
>  	spin_lock_bh(&br->lock);
>  	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
