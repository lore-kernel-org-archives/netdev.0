From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH 06/11] net: usb: mcs7830: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 15:36:20 +0100
Message-ID: <dc26076e-7ef5-17f1-33c9-fabcb84dd66d@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
 <1489702737-2401-7-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, oliver@neukum.org,
        jacmet@sunsite.dk, steve.glendinning@shawell.net,
        UNGLinuxDriver@microchip.com, gregkh@linuxfoundation.org,
        davem@davemloft.net, robert.foss@collabora.com, allan@asix.com.tw,
        grundler@google.com, jarod@redhat.com, peter.chen@nxp.com,
        stefan.bruens@rwth-aachen.de, akpm@linux-foundation.org,
        adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33088 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757017AbdCUOkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 10:40:14 -0400
In-Reply-To: <1489702737-2401-7-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.03.2017 23:18, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/usb/mcs7830.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
> index 4f345bd..5771ff2 100644
> --- a/drivers/net/usb/mcs7830.c
> +++ b/drivers/net/usb/mcs7830.c
> @@ -464,9 +464,9 @@ static void mcs7830_get_regs(struct net_device *net, struct ethtool_regs *regs,
>  	.get_link		= usbnet_get_link,
>  	.get_msglevel		= usbnet_get_msglevel,
>  	.set_msglevel		= usbnet_set_msglevel,
> -	.get_settings		= usbnet_get_settings,
> -	.set_settings		= usbnet_set_settings,
>  	.nway_reset		= usbnet_nway_reset,
> +	.get_link_ksettings	= usbnet_get_link_ksettings,
> +	.set_link_ksettings	= usbnet_set_link_ksettings,
>  };
>  
>  static const struct net_device_ops mcs7830_netdev_ops = {
> 

$ modinfo mcs7830 usbnet mii -n
/lib/modules/4.11.0-0.rc3.git0.1.fc26.x86_64/updates/mcs7830.ko
/lib/modules/4.11.0-0.rc3.git0.1.fc26.x86_64/updates/usbnet.ko
/lib/modules/4.11.0-0.rc3.git0.1.fc26.x86_64/updates/mii.ko

$ lsmod | grep mcs7830
mcs7830                16384  0
usbnet                 45056  1 mcs7830
mii                    16384  2 usbnet,mcs7830

$ nmcli -f GENERAL.DRIVER,GENERAL.STATE device show enp0s4f1u4
GENERAL.DRIVER:                         MOSCHIP usb-ethernet driver
GENERAL.STATE:                          100 (connected)

Tested-by: poma <poma@gmail.com>
