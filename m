From: Christoph Hellwig <hch@infradead.org>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Tue, 21 Feb 2006 20:32:11 +0000
Message-ID: <20060221203211.GA29627@infradead.org>
References: <11403021213131-git-send-email-carlos@cmartin.tk> <20060221192601.GA28560@infradead.org> <200602212124.23572.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Carlos Mart?n <carlos@cmartin.tk>
Content-Disposition: inline
In-Reply-To: <200602212124.23572.carlos@cmartin.tk>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2006 at 09:24:23PM +0100, Carlos Mart?n wrote:
> > acx-common-y		+= wlan.o conv.o ioctl.o common.o
> > acx-pci-y		+= pci.o
> > acx-usb-y		+= usb.o
> > 
> > obj-$(CONFIG_ACX_PCI)	+= acx-common.o acx-pci.o
> > obj-$(CONFIG_ACX_USB)	+= acx-common.o acx-usb.o
> 
> This is how we had it before, which leads to having a lot of the same code on 
> both modules. The unified driver is not much larger so it was made this way, 
> and that's where all the problem comes from.
> Wouldn't this lead to duplicated function definitions at link time if both are 
> compiled-in? From your module split above I understood you wanted acx-common 
> to be another module, but here I see it goes into the modules.
> 

No.  The above makefile fragment builds three modules: acx-common.o,
acx-pci.o and acx-usb.o as mentioned above.  The magic here is that with
that makefile fragment is that the kbuild systems builds acx-common.o if
either CONFIG_ACX_PCI or CONFIG_ACX_USB is set, and even makes sure to
do the right thing if either is builtin.  There is not code duplication
at all.

> > ---- snip ----
> > 
> >  - kill the IS_PCI/IS_USB macros and add a acx_operations structure that
> >    handles the different hardware without branches all over and allows
> >    the hw-specific code to be in separate modules.
> 
> There aren't that many IS_{PCI,USB} uses and most if not all are justified 
> (extra step for one case). It might be a good idea to do that for the 
> IS_ACX{100,111} macros instead of calling the generic function which then 
> calls the chip-specific one.

The important bit is that you need the pointers with the above module
spit, because you can't call usb- or pci-specific routines from acx-common.ko


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
