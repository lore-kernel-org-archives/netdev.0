From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V5 PATCH 2/3] Add ndo_{set|get}_vf_port_profile op support for enic dynamic vnics
Date: Thu, 6 May 2010 15:47:22 +0200
Message-ID: <201005061547.22400.arnd@arndb.de>
References: <20100506044200.29677.20604.stgit@savbu-pc100.cisco.com> <20100506044211.29677.59331.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60176 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758222Ab0EFNr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 09:47:27 -0400
In-Reply-To: <20100506044211.29677.59331.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 May 2010, Scott Feldman wrote:
> @@ -810,14 +819,24 @@ static void enic_reset_mcaddrs(struct enic *enic)
>  
>  static int enic_set_mac_addr(struct net_device *netdev, char *addr)
>  {
> -       if (!is_valid_ether_addr(addr))
> -               return -EADDRNOTAVAIL;
> +       struct enic *enic = netdev_priv(netdev);
>  
> -       memcpy(netdev->dev_addr, addr, netdev->addr_len);
> +       if (enic_is_dynamic(enic)) {
> +               random_ether_addr(netdev->dev_addr);
> +       } else {
> +               if (!is_valid_ether_addr(addr))
> +                       return -EADDRNOTAVAIL;
> +               memcpy(netdev->dev_addr, addr, netdev->addr_len);
> +       }
>  
>         return 0;
>  }
>  
> +static int enic_set_mac_address(struct net_device *netdev, void *p)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
>  /* netif_tx_lock held, BHs disabled */
>  static void enic_set_multicast_list(struct net_device *netdev)
>  {

Thsi looks funny. So you just ignore the address that gets passed to
enic_set_mac_addr for dynamic interfaces and instead set a random
address?

	Arnd
