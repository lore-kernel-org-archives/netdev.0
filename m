From: Gergely Madarasz <gorgo@thunderchild.debian.net>
Subject: Re: comx drivers in 2.6
Date: Sat, 19 Jul 2003 10:14:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030719081400.GP1553@bpdcad01.bpdc.broadband.hu>
References: <20030717163337.78d123c0.shemminger@osdl.org> <3F173458.6060405@pobox.com> <20030718123625.6f8ae9b9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Gergely Madarasz <gorgo@itc.hu>,
   netdev@oss.sgi.com, don@itc.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030718123625.6f8ae9b9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 18, 2003 at 12:36:25PM -0700, Stephen Hemminger wrote:
> On Thu, 17 Jul 2003 19:42:16 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Stephen Hemminger wrote:
> > > It looks like the comx drivers never got updated for 2.5/2.6.  Some
> > > obvious issues are:
> > > 	- lots of use of /proc files without setting the owner field.
> > > 	- still using cli/sti
> > > 	- no SMP locking on the linked list (which could be changed to list macros)
> > > 	  of hardware and protocols.
> > > 
> > > Just bumped into this while trying to inspect for all the last possible
> > > broken usage of net_device structure.  It is too far behind to address
> > > those issues.
> > 
> > 
> > Submit a patch to mark these CONFIG_OBSOLETE.  AFAIK nobody has cared 
> > for most of them since 2.2...  (munich is an exception)
> > 
> 
> diff -Nru a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
> --- a/drivers/net/wan/Kconfig	Fri Jul 18 11:55:47 2003
> +++ b/drivers/net/wan/Kconfig	Fri Jul 18 11:55:47 2003
> @@ -60,9 +60,10 @@
>  #
>  # COMX drivers
>  #
> +# Not updated to 2.6.
>  config COMX
>  	tristate "MultiGate (COMX) synchronous serial boards support"
> -	depends on WAN && (ISA || PCI)
> +	depends on WAN && (ISA || PCI) && OBSOLETE
>  	---help---
>  	  Say Y if you want to use any board from the MultiGate (COMX) family.
>  	  These boards are synchronous serial adapters for the PC,

Please add the following patch too.
I'm suprised I'm still not removed from the maintainers file, though I
have left itc almost two years ago. 

--- MAINTAINERS~        Mon Jul 14 05:35:12 2003
+++ MAINTAINERS Sat Jul 19 10:12:14 2003
@@ -420,8 +420,8 @@
 S:     Supported
 
 COMX/MULTIGATE SYNC SERIAL DRIVERS
-P:     Gergely Madarasz
-M:     Gergely Madarasz <gorgo@itc.hu>
+P:     Pasztor Szilard
+M:     Pasztor Szilard <don@itc.hu>
 S:     Supported
 
 COSA/SRP SYNC SERIAL DRIVER


-- 
Madarasz Gergely   gorgo@thunderchild.debian.net   gorgo@linux.rulez.org
    It's practically impossible to look at a penguin and feel angry.
        Egy pingvinre gyakorlatilag lehetetlen haragosan nezni.
