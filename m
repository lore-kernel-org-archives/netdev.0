From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: Network device driver probe issues
Date: Fri, 16 Jul 2004 12:15:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E01CEF1BF@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, "Anton Blanchard" <anton@samba.org>,
        "Netdev" <netdev@oss.sgi.com>, "cramerj" <cramerj@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>, <jonmason@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jim Keniston" <jkenisto@us.ibm.com>, "David Dillow" <dave@thedillows.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We've fixed the e100 to have the same logic as e1000. I like the typhoon
driver idea.

Thanks,
ganesh 
 
-------------------------------------------------
Ganesh Venkatesan
Network/Storage Division, Hillsboro, OR

-----Original Message-----
From: Jim Keniston [mailto:jkenisto@us.ibm.com] 
Sent: Friday, July 16, 2004 11:27 AM
To: David Dillow
Cc: Jeff Garzik; Anton Blanchard; Netdev; cramerj; Ronciak, John;
Venkatesan, Ganesh; jonmason@us.ibm.com; Jim Keniston
Subject: Re: Network device driver probe issues

On Thu, 2004-07-15 at 21:49, David Dillow wrote:
> On Thu, 2004-07-15 at 21:04, Jim Keniston wrote:
> > On Thu, 2004-07-15 at 16:34, Jeff Garzik wrote:
> [snip]
> > > > We should instead use something stable to attach to printks
during
> > > > probe. pci_name() is the obvious choice, perhaps using
dev_printk().
> > > > The failure then becomes:
> > > > 
> > > > 0000:01:01.0 Intel(R) PRO/1000 Network Connection
> > > > 0000:01:01.0 The EEPROM Checksum Is Not Valid
> > > > 0000:02:01.0 Intel(R) PRO/1000 Network Connection
> > > 
> > > pci_name() or a simple counter of devices found.  I prefer
pci_name()
> > > 
> > > 	Jeff
> > 
> > Delay registration until the end of the probe, and make DPRINTK
smarter.
> > DPRINTK should check
> > 	adapter->netdev->reg_state == NETREG_REGISTERED
> > and use the interface name (eth0) if the device is registered, or
> > pci_name() if it's not.
> > 
> > Jim
> 
> In the typhoon driver, I have tp->name, and most everything that
prints
> info/errors about the card use it. During probing, it is initially set
> to point to pci_name(), and once registered, it gets pointed to
> netdev->name.
> 
> This seems fairly clean, though maybe a bit redundant.
> 
> Dave
> 

Works for me.  While we're talking about DPRINTK, e100.c could use a
similar adjustment.  e100_probe() correctly defers registration until
the probe has succeeded, but as a result, probe-time failure messages
refer to "eth%d", right?

Jim
