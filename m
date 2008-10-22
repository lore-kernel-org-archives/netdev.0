From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] e1000e: get rid of wasted space
Date: Wed, 22 Oct 2008 11:07:07 -0700
Message-ID: <20081022110707.3ab8f68b@extreme>
References: <20081020191149.1dbf8e3b@extreme>
	<48FF0882.9050007@garzik.org>
	<EA929A9653AAE14F841771FB1DE5A1365F49CD6EE4@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44192 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbYJVSHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 14:07:10 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F49CD6EE4@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2008 12:01:16 -0600
"Williams, Mitch A" <mitch.a.williams@intel.com> wrote:

> Jeff Garzik wrote:
> 
> >
> >Stephen Hemminger wrote:
> >> The name in the ring is only used once during setup so it shouldn't
> >> be in the data structure.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> [snip]
> >
> >ACK
> >
> >for what it's worth...  I am following DaveM's lead, and waiting until
> >net-next opens to start taking patches for 2.6.29.  He wants
> >us to focus
> >on bug fixing for now.
> >
> >So, please resend once the merge window opens... thanks.
> >
> 
> NAK.  Seriously. Don't resend this.  NAK.
> 
> That string DOES get used later, like when you cat /proc/interrupts.
> So you can't allocate it on the stack.  It's got to be persistent,
> just like we have it.  Heck, look at the declaration for
> request_irq().  The devname param is declared as const char *.
> 
> So NAK.  Same for igb and ixgbe.  Don't do this.
> 
> -Mitch

The comments were right, this needs to stay, although it might be better
to use a bigger field to allow full width of IFNAME+5

