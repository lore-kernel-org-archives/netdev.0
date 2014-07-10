From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v7 03/33] net: set name_assign_type in alloc_netdev()
Date: Thu, 10 Jul 2014 11:16:50 +0200
Message-ID: <87tx6ph8u5.fsf@nemi.mork.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	<1404980258-30853-4-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-4-git-send-email-teg@jklm.no> (Tom Gundersen's
	message of "Thu, 10 Jul 2014 10:17:08 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Gundersen <teg@jklm.no> writes:

> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 5dc638c..f405e05 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -390,7 +390,8 @@ EXPORT_SYMBOL(ether_setup);
>  struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int =
txqs,
>  				      unsigned int rxqs)
>  {
> -	return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txqs, rx=
qs);
> +	return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNOWN,
> +				ether_setup, txqs, rxqs);
>  }
>  EXPORT_SYMBOL(alloc_etherdev_mqs);

I believe this chunk makes the rest of this exercise pretty pointless.

bjorn@nemi:/usr/local/src/git/linux$ git grep alloc_etherdev drivers/ne=
t/|wc -l
283

I don't care enough to go look, but I'd be surprised if none of those
drivers rename the device before registering it.


Bj=C3=B8rn
