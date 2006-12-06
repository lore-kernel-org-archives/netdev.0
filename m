From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/7] chelsio: use netdev_priv
Date: Tue, 5 Dec 2006 16:39:21 -0800
Message-ID: <20061205163921.61ea21e6@dxpl.pdx.osdl.net>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
	<20061206001652.GD2377@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:59058 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758829AbWLFAjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:39:39 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061206001652.GD2377@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Dec 2006 01:16:52 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/chelsio/cxgb2.c |   60 +++++++++++++++++++++---------------------
>  drivers/net/chelsio/sge.c   |    4 +-
>  2 files changed, 32 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
> index cb639d4..15be058 100644
> --- a/drivers/net/chelsio/cxgb2.c
> +++ b/drivers/net/chelsio/cxgb2.c
> @@ -120,7 +120,7 @@ static const char pci_speed[][4] = {
>   */
>  static void t1_set_rxmode(struct net_device *dev)
>  {
> -	struct adapter *adapter = dev->priv;
> +	struct adapter *adapter = netdev_priv(dev);
>  	struct cmac *mac = adapter->port[dev->if_port].mac;
>  	struct t1_rx_mode rm;
> 

NAK for this driver. dev->priv points to a different location for each port on
dual port board.  To use netdev_priv() requires more serious surgery..


