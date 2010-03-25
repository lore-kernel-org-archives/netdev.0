From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] e1000e: Use pr_<level> and netdev_<level>
Date: Wed, 24 Mar 2010 17:04:34 -0700
Message-ID: <1269475474.1541.20.camel@Joe-Laptop.home>
References: <20100324225529.7104.17189.stgit@localhost.localdomain>
	 <1269474180.1541.11.camel@Joe-Laptop.home>
	 <8DD2590731AB5D4C9DBF71A877482A9061B3334E@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1068 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363Ab0CYAEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 20:04:36 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9061B3334E@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-24 at 16:54 -0700, Allan, Bruce W wrote:
> On Wednesday, March 24, 2010 4:43 PM, Joe Perches wrote:
> > On Wed, 2010-03-24 at 15:55 -0700, Jeff Kirsher wrote:
> >> From: Bruce Allan <bruce.w.allan@intel.com>
> >> As an alternative to a quite large patch previously submitted by Joe
> >> Perches to make use of kernel logging API, this patch is much less
> >> intrusive.
> > []
> >> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> >> index 118bdf4..23ab67c 100644 --- a/drivers/net/e1000e/e1000.h
> >> +++ b/drivers/net/e1000e/e1000.h
> >> @@ -42,25 +42,16 @@
> >> 
> >>  struct e1000_info;
> >> 
> >> -#define e_printk(level, adapter, format, arg...) \
> >> -	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
> >> -	       adapter->netdev->name, ## arg)
> >> -
> >> -#ifdef DEBUG
> >>  #define e_dbg(format, arg...) \
> >> -	e_printk(KERN_DEBUG , hw->adapter, format, ## arg)
> >> -#else
> >> -#define e_dbg(format, arg...) do { (void)(hw); } while (0)
> >> -#endif
> >> -
> >> +	netdev_dbg(hw->adapter->netdev, format, ## arg)
> >>  #define e_err(format, arg...) \
> >> -	e_printk(KERN_ERR, adapter, format, ## arg)
> >> +	netdev_err(adapter->netdev, format, ## arg)
> >>  #define e_info(format, arg...) \
> >> -	e_printk(KERN_INFO, adapter, format, ## arg)
> >> +	netdev_info(adapter->netdev, format, ## arg)
> >>  #define e_warn(format, arg...) \
> >> -	e_printk(KERN_WARNING, adapter, format, ## arg)
> >> +	netdev_warn(adapter->netdev, format, ## arg)
> >>  #define e_notice(format, arg...) \
> >> -	e_printk(KERN_NOTICE, adapter, format, ## arg)
> >> +	netdev_notice(adapter->netdev, format, ## arg)
> > 
> > Macros that use global variables are undesirable.
> > I think there's value in using standard mechanisms.
> > 
> No global variable is used - both adapter and hw are either a local
> variable or a passed in parameter for all functions that use these macros.

hw and adapter are locally scoped in each function here,
but are not local to the macro.  That can make conversions
of macros to functions difficult.

It's your code, not mine.
Proving the conversion correct is pretty trivial.
Do what's best.

cheers, Joe

