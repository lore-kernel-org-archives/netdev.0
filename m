From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 3/8] netback: get/put module along with vif
 connect/disconnect
Date: Tue, 5 Mar 2013 10:53:35 -0500
Message-ID: <20130305155335.GC15431@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
 <5135C2C8.8030708@citrix.com>
 <1362490213.4748.24.camel@zion.uk.xensource.com>
 <5135FC2E.9050705@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51689 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027Ab3CEPxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 10:53:41 -0500
Content-Disposition: inline
In-Reply-To: <5135FC2E.9050705@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 05, 2013 at 02:07:42PM +0000, David Vrabel wrote:
> On 05/03/13 13:30, Wei Liu wrote:
> > On Tue, 2013-03-05 at 10:02 +0000, David Vrabel wrote:
> >> On 15/02/13 16:00, Wei Liu wrote:
> >>> If there is vif running and user unloads netback, guest's network interface
> >>> just mysteriously stops working. So we need to prevent unloading netback
> >>> module if there is vif running.
> >>
> >> It's not mysterious -- it is cleanly disconnected, and will reconnect
> >> when the module is reinserted.
> >>
> > 
> > From a guest's POV, it just stops without any sign. This should be
> > prevented IMHO.
> 
> This is a bug in the frontend or a bug in the backend failing to
> disconnect correctly.
> 
> I posted a series of "xen-foofront: handle backend CLOSED without
> CLOSING" patches that may help here. (I didn't get applied to netfront
> for some reason.)

Hm, could you resent it please and make sure that the networking
maintainer is on the To list?

> 
> Disabling module unload doesn't prevent this from happening away.  You
> can always manually unbind the backend device from the xen-netback
> driver which has the same effect as unloading the module.
> 
> > Netback / netfront lose all states when netback is unloaded. And
> > netfront doesn't support reconfiguration at the moment. My guess is that
> > this is the reason why netback doesn't even have unload function at
> > first.
> 
> If netfront cannot handle reconnect then that's a bug in the frontend or
> a bug in the backend xenbus code not setting up the reconnect correctly.
> 
> >> Being able to unload modules while they are in use is standard so I
> >> don't think this should be applied.
> > 
> > I don't think this is true from a module dependency point of view - just
> > try to unload any in use module, rmmod / modprobe will give you a fatal
> > error.
> 
> Try it with any other network interface driver and it will unload just fine.
> 
> David
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
