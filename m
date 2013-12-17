From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2 3/9] bridge: Fix the way to find old local fdb
 entries in br_fdb_change_mac_address
Date: Tue, 17 Dec 2013 11:01:16 -0500
Message-ID: <52B0754C.4020009@redhat.com>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1387281821-21342-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754318Ab3LQQBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 11:01:25 -0500
In-Reply-To: <1387281821-21342-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> We have been always failed to delete the old entry at
> br_fdb_change_mac_address() because br_set_mac_address() updates
> dev->dev_addr before calling br_fdb_change_mac_address() and
> br_fdb_change_mac_address() uses dev->dev_addr to find the old entry.
> 
> That update of dev_addr is completely unnecessary because the same work
> is done in br_stp_change_bridge_id() which is called right away after
> calling br_fdb_change_mac_address().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_device.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index f00cfd2..d967773 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -187,8 +187,8 @@ static int br_set_mac_address(struct net_device *dev, void *p)
>  
>  	spin_lock_bh(&br->lock);
>  	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
> -		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
>  		br_fdb_change_mac_address(br, addr->sa_data);
> +		/* Mac address will be changed in br_stp_change_bridge_id(). */
>  		br_stp_change_bridge_id(br, addr->sa_data);
>  	}
>  	spin_unlock_bh(&br->lock);
> 
