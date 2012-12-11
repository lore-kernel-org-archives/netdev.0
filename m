From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] smsc75xx: only set mac address once on bind
Date: Tue, 11 Dec 2012 08:59:27 -0600
Message-ID: <1355237967.23548.4.camel@dcbw.foobar.com>
References: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
	 <1355180407.19156.32.camel@dcbw.foobar.com>
	 <CAKh2mn4i0uwfLeO4yvujJn3nvu3MbsTmrOJp_6uk1ezQMF6V+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, Bjorn Mork <bjorn@mork.no>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781Ab2LKO6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 09:58:20 -0500
In-Reply-To: <CAKh2mn4i0uwfLeO4yvujJn3nvu3MbsTmrOJp_6uk1ezQMF6V+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 14:35 +0000, Steve Glendinning wrote:
> Hi Dan,
> 
> On 10 December 2012 23:00, Dan Williams <dcbw@redhat.com> wrote:
> > On Mon, 2012-12-10 at 11:01 +0000, Steve Glendinning wrote:
> >> This patch changes when we decide what the device's MAC address
> >> is from per ifconfig up to once when the device is connected.
> >>
> >> Without this patch, a manually forced device MAC is overwritten
> >> on ifconfig down/up.  Also devices that have no EEPROM are
> >> assigned a new random address on ifconfig down/up instead of
> >> persisting the same one.
> >
> > Does this mean that on devices without EEPROM, ifconfig XXX
> > down/ifconfig XXX up will generate a *new* random address?  That seems a
> > bit odd; why wouldn't the first random address generated for the device
> > persist until either (a) changed by ifconfig or (b) device was
> > disconnected?
> 
> Sorry if my commit message wasn't clear enough.  That is indeed a bit
> odd, and it describes the (buggy) behaviour BEFORE this patch was
> applied.
> 
> With this patch applied, devices without EEPROM (and without a
> manually specified MAC address) will get a randomly generated address
> assigned once at bind time, so this MAC will persist for the lifetime
> the USB device is connected.  We also now won't trash a manually
> specified MAC, for cases where userland sets the MAC before bringing
> up the interface.

Excellent, thanks for the clarification.

Dan
