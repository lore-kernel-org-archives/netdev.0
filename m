From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] and enhancements to pcnet32.c for 2.6.3-rc2
Date: Tue, 17 Feb 2004 14:54:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217145430.38ad5692.rddunlap@osdl.org>
References: <200402172131.i1HLVvv02518@dyn318364bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200402172131.i1HLVvv02518@dyn318364bld.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004 13:31:57 -0800 (PST) Don Fry <brazilnut@us.ibm.com> wrote:

| Attached is a collection of patches for the pcnet32 driver.
| 
| The maintainer has not responded to the following three patches.

Since this email has received such wide reviews in the past, here
are some more comments on it.

a.  make separate patches based on functional changes, not a collection
of patches.

b.  don't use C++-style "//" comments: Linux style is /* ... */



| @@ -213,6 +223,13 @@
|   *	   clean up and using new mii module
|   * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
|   * 	   Added timer for cable connection state changes.
| + * v1.28   11 Feb 2004 Don Fry <brazilnut@us.ibm.com>,
| + *	   Jon Mason <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>,
| + *	   Jim Lewis <jklewis@us.ibm.com>.
| + *	   Now uses ethtool_ops, netif_msg_*, and generic_mii_ioctl.
| + *	   Loopback test added.  Supports PCI (not PCMCIA) hot remove.
| + *	   Fixes "Bus master arbitration failure" and pci_[un]map_single
| + *	   length errors.
|   */

This should go in the changeset comments.


| @@ -841,8 +1131,10 @@
|      }
|  
|      /* Check for a valid station address */
| -    if( !is_valid_ether_addr(dev->dev_addr) )
| -	return -EINVAL;
| +    if( !is_valid_ether_addr(dev->dev_addr) ) {

Too ugly.  Use:
	if (!is_xyz()) {


| +	ret = -EINVAL;
| +	goto err_free_irq;
| +    }


--
~Randy
