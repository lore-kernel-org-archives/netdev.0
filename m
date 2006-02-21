From: Christoph Hellwig <hch@infradead.org>
Subject: Re: From: Carlos   Mart??n <carlos@cmartin.tk>
Date: Tue, 21 Feb 2006 19:26:01 +0000
Message-ID: <20060221192601.GA28560@infradead.org>
References: <11403021213131-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Carlos Martin <carlos@cmartin.tk>
Content-Disposition: inline
In-Reply-To: <11403021213131-git-send-email-carlos@cmartin.tk>
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

On Sat, Feb 18, 2006 at 11:35:21PM +0100, Carlos Martin wrote:
> [PATCH] acxsm: Fix Kconfig option check
> 
> This check never actually worked because CONFIG_ACX_{ACX,USB} are
> tristate. With Adrian Bunk's patch to the Kconfig, this works with the
> _BOOL hidden Kconfig options.
> Also update error message adding that this shouldn't happen anymore.

All the fixes discussed so far are not very nice at all.  The right
fix is the following:


 - split the module into three:
	acx-common.ko
	acx-pci.ko
	acx-usb.ko

 - make CONFIG_ACX_PCI and CONFIG_ACX_USB user-visible tristate
   varibles in the Kconfig.
 - build acx-common.ko when either of those is selected, with the
   following makefile:

---- snip ----
acx-common-y		+= wlan.o conv.o ioctl.o common.o
acx-pci-y		+= pci.o
acx-usb-y		+= usb.o

obj-$(CONFIG_ACX_PCI)	+= acx-common.o acx-pci.o
obj-$(CONFIG_ACX_USB)	+= acx-common.o acx-usb.o
---- snip ----

 - kill the IS_PCI/IS_USB macros and add a acx_operations structure that
   handles the different hardware without branches all over and allows
   the hw-specific code to be in separate modules.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
