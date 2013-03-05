From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 3/8] netback: get/put module along with vif
 connect/disconnect
Date: Tue, 5 Mar 2013 13:30:13 +0000
Message-ID: <1362490213.4748.24.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
	 <5135C2C8.8030708@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54643 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab3CENaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 08:30:15 -0500
In-Reply-To: <5135C2C8.8030708@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 10:02 +0000, David Vrabel wrote:
> On 15/02/13 16:00, Wei Liu wrote:
> > If there is vif running and user unloads netback, guest's network interface
> > just mysteriously stops working. So we need to prevent unloading netback
> > module if there is vif running.
> 
> It's not mysterious -- it is cleanly disconnected, and will reconnect
> when the module is reinserted.
> 

>From a guest's POV, it just stops without any sign. This should be
prevented IMHO.

Netback / netfront lose all states when netback is unloaded. And
netfront doesn't support reconfiguration at the moment. My guess is that
this is the reason why netback doesn't even have unload function at
first.

> Being able to unload modules while they are in use is standard so I
> don't think this should be applied.
> 

I don't think this is true from a module dependency point of view - just
try to unload any in use module, rmmod / modprobe will give you a fatal
error.

The situation for netback is a bit different. The module dependency is
not within the same kernel, we can only do this by explicitly get/put
this module.


Wei.
