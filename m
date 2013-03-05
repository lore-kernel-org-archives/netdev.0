From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 3/8] netback: get/put module along with vif
 connect/disconnect
Date: Tue, 5 Mar 2013 14:44:19 +0000
Message-ID: <1362494659.4748.36.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
	 <5135C2C8.8030708@citrix.com>
	 <1362490213.4748.24.camel@zion.uk.xensource.com>
	 <5135FC2E.9050705@citrix.com>
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
Received: from smtp02.citrix.com ([66.165.176.63]:26965 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab3CEOoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 09:44:20 -0500
In-Reply-To: <5135FC2E.9050705@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 14:07 +0000, David Vrabel wrote:
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
> 

Any links? And the reason why it was not applied?

> Disabling module unload doesn't prevent this from happening away.  You
> can always manually unbind the backend device from the xen-netback
> driver which has the same effect as unloading the module.
> 

Yes, but that's not a normal use case.

> > Netback / netfront lose all states when netback is unloaded. And
> > netfront doesn't support reconfiguration at the moment. My guess is that
> > this is the reason why netback doesn't even have unload function at
> > first.
> 
> If netfront cannot handle reconnect then that's a bug in the frontend or
> a bug in the backend xenbus code not setting up the reconnect correctly.
> 

AFAICT, various frontends (hvc, fb, blk etc.) don't respond to Closing
Closed Reconfigur{ing,ed} XenbusState. Is it the "bug" you're referring
to?

> >> Being able to unload modules while they are in use is standard so I
> >> don't think this should be applied.
> > 
> > I don't think this is true from a module dependency point of view - just
> > try to unload any in use module, rmmod / modprobe will give you a fatal
> > error.
> 
> Try it with any other network interface driver and it will unload just fine.
> 

I don't think we are talking about the same thing here...

If you unload a network module in Dom0, that's fine, because you lose
your interface in Dom0 as well. But for a DomU, frontend don't know
about this.



Wei.

> David
