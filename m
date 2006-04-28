From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 17/32] rt2x00: Put net_device structure in data_ring
Date: Fri, 28 Apr 2006 13:45:21 +0200
Message-ID: <200604281345.22006.netdev@axxeo.de>
References: <200604280003.09753.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:55764 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S965201AbWD1Lpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 07:45:33 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604280003.09753.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ivo,

Ivo van Doorn wrote:
> diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> --- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-04-27 21:48:21.000000000 +0200
> +++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-04-27 21:49:08.000000000 +0200
> @@ -760,10 +760,8 @@ rt2400pci_write_tx_desc(
>  static void
>  rt2400pci_beacondone(void *data)
>  {
> -	struct data_ring	*ring = (struct data_ring*)data;
> -	struct rt2x00_pci	*rt2x00pci = (struct rt2x00_pci*)ring->dev;
> -	struct net_device	*net_dev = pci_get_drvdata(rt2x00pci->pci_dev);
> -	struct sk_buff		*skb;
> +	struct data_ring		*ring = (struct data_ring*)data;

No need for a cast here. 
In C you can cast from any struct pointer to void pointer and back
without problems.

> @@ -784,8 +782,8 @@ static void
>  rt2400pci_rxdone(void *data)
>  {
>  	struct data_ring	*ring = (struct data_ring*)data;

No need for casting.

> @@ -835,8 +834,8 @@ static void
>  rt2400pci_txdone(void *data)
>  {
>  	struct data_ring	*ring = (struct data_ring*)data;

No need for casting.

> diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> --- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-04-27 21:48:21.000000000 +0200
> +++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-04-27 21:49:08.000000000 +0200
> @@ -834,10 +834,8 @@ rt2500pci_write_tx_desc(
>  static void
>  rt2500pci_beacondone(void *data)
>  {
> -	struct data_ring	*ring = (struct data_ring*)data;
> -	struct rt2x00_pci	*rt2x00pci = (struct rt2x00_pci*)ring->dev;
> -	struct net_device	*net_dev = pci_get_drvdata(rt2x00pci->pci_dev);
> -	struct sk_buff		*skb;
> +	struct data_ring		*ring = (struct data_ring*)data;

No need for casting.

Many more of them.

I guess you could just do a fgrep for "*ring = (struct data_ring*)data;"

Regards

Ingo Oeser
