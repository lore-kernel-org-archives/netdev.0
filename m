From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: Network device driver probe issues
Date: 15 Jul 2004 18:04:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089939860.1709.70.camel@ibm-ni9dztukfq8.beaverton.ibm.com>
References: <20040715135244.GD27715@krispykreme>
	 <40F71477.2020408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com, cramerj@intel.com,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jonmason@us.ibm.com, Jim Keniston <jkenisto@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40F71477.2020408@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 16:34, Jeff Garzik wrote:
> Anton Blanchard wrote:
> > The e1000 gets around this by replicating register_netdev:
> > 
> > [snipped]
> > 
> > The problem I have with this method has to do with how failures appear
> > to the user. If you have two network cards and the first one fails
> > during probe you will see:
> 
> Agreed, this is a hack and strongly discouraged.
> 
> Hopefully Intel will hear this and send me a patch to fix... :)
> 
> 
> > We should instead use something stable to attach to printks during
> > probe. pci_name() is the obvious choice, perhaps using dev_printk().
> > The failure then becomes:
> > 
> > 0000:01:01.0 Intel(R) PRO/1000 Network Connection
> > 0000:01:01.0 The EEPROM Checksum Is Not Valid
> > 0000:02:01.0 Intel(R) PRO/1000 Network Connection
> 
> pci_name() or a simple counter of devices found.  I prefer pci_name()
> 
> 	Jeff

Delay registration until the end of the probe, and make DPRINTK smarter.
DPRINTK should check
	adapter->netdev->reg_state == NETREG_REGISTERED
and use the interface name (eth0) if the device is registered, or
pci_name() if it's not.

Jim
