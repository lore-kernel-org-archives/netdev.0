From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Network device driver probe issues
Date: Thu, 15 Jul 2004 19:34:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40F71477.2020408@pobox.com>
References: <20040715135244.GD27715@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, cramerj@intel.com, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jonmason@us.ibm.com, jkenisto@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040715135244.GD27715@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> The e1000 gets around this by replicating register_netdev:
> 
>         rtnl_lock();
>         /* we need to set the name early since the DPRINTK macro needs it set */
>         if (dev_alloc_name(netdev, netdev->name) < 0)
>                 goto err_free_unlock;
> 
> ...
> 
>         /* since we are holding the rtnl lock already, call the no-lock version */
>         if((err = register_netdevice(netdev)))
>                 goto err_register;
> 
>         cards_found++;
>         rtnl_unlock();
> 
> The problem I have with this method has to do with how failures appear
> to the user. If you have two network cards and the first one fails
> during probe you will see:

Agreed, this is a hack and strongly discouraged.

Hopefully Intel will hear this and send me a patch to fix... :)


> We should instead use something stable to attach to printks during
> probe. pci_name() is the obvious choice, perhaps using dev_printk().
> The failure then becomes:
> 
> 0000:01:01.0 Intel(R) PRO/1000 Network Connection
> 0000:01:01.0 The EEPROM Checksum Is Not Valid
> 0000:02:01.0 Intel(R) PRO/1000 Network Connection

pci_name() or a simple counter of devices found.  I prefer pci_name()

	Jeff
