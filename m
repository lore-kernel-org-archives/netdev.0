From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v4 1/1] net/hsr: Support for the HSR protocol (IEC:2010 /
 HSR v0)
Date: Fri, 12 Oct 2012 11:57:15 -0700
Message-ID: <20121012115715.11b6be24@nehalam.linuxnetplumber.net>
References: <4FF38A5C.9000802@xdin.com>
	<1341361824.1993.16.camel@joe2Laptop>
	<502D475C.9090208@xdin.com>
	<20120816.133036.1422214989121265534.davem@davemloft.net>
	<50784F2D.1060200@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"jboticario@gmail.com" <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59928 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab2JLS55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 14:57:57 -0400
In-Reply-To: <50784F2D.1060200@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Oct 2012 17:11:12 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> This would add support for the High-availability Seamless Redundancy network
> protocol, version 0 (2010).
> 
> This RFC is NOT meant for mainline inclusion at the moment since we're trying
> to figure out how to handle a probable incompatibility with the newer
> HSR v1 (2012) standard.
> 
> ---
> 
> This RFC is mainly to let you know that I'm still working on this patch. This
> is now a pretty complete implementation of the HSR v0 (2010) protocol. As
> explained above, the main reason I'm still not sending this as a real patch
> meant for mainline inclusion, is the fact that IEC recently released an updated
> standard (HSR v1 / 2012) which as far as I can tell is not backwards compatible
> with the 2010 standard implemented by this patch.
> 
> At the moment we're trying to figure out what to do about this.
> 
> Changes from RFC v3:
> 
> 	* Fixed style issues.
> 	* More thorough device stats updates.
> 	* Fixed bug where node that is downed and restarted within
> 	  NODE_FORGET_TIME is never seen by other nodes.
> 	* In RFC v3, a slave that was unregistered (e.g. USB network device that
> 	  was unplugged) would crash the kernel. Works OK now.
> 	* Slave envent handling: MTU change, MAC address change, unregister,
> 	  type change.
> 	* Master event handling: MTU change.
> 	* Removed NONSTANDARD_HSR config option.
> 	* Guards for VLAN/HSR combo (allowed by the HSR standard, but not yet
> 	  implemented).
> 
> The patch has mostly been tested on 2.6.37, then modified to apply and compile
> on 3.6.1.

Thanks for keeping up with this, I know it must seem like a long
struggle to get it upstream.

1. Since this is new functionality, it should be submitted against net-next
   tree. Dave isn't accepting patches for that yet.
2. Lots of formatting issues. Please run checkpatch.
3. Minor nits:

Could this be replaced by netif_running()?
+static bool is_admin_up(struct net_device *dev)
+{
+	return (dev && (dev->flags & IFF_UP));
+}

And this by netif_oper_up()?

+static bool is_operstate_up(struct net_device *dev)
+{
+	return (dev && (dev->operstate == IF_OPER_UP));
+}
+
