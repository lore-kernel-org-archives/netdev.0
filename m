From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [patch 4/8 2.5] e1000 Check value returned by from
	pci_enable_device
Date: Fri, 17 Sep 2004 20:05:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095476710.3496.13.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0409170233040.15233-100000@isotope.jf.intel.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0409170233040.15233-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-17 at 02:57, Ganesh Venkatesan wrote:
> diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
> --- linux-2.5/drivers/net/e1000/e1000_main.c	2004-09-09 11:17:11.000000000 -0700
> +++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-09-09 11:17:12.000000000 -0700
> @@ -2881,9 +2881,9 @@ e1000_resume(struct pci_dev *pdev)
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct e1000_adapter *adapter = netdev->priv;
> -	uint32_t manc;
> +	uint32_t manc, ret;
>  
> -	pci_enable_device(pdev);
> +	ret = pci_enable_device(pdev);
>  	pci_set_power_state(pdev, 0);
>  	pci_restore_state(pdev, adapter->pci_state);

Where is the check of the return value?  I just see an assignment to an
automatic that gets tossed (probably by the compiler if it's paying
attention).

-scott
